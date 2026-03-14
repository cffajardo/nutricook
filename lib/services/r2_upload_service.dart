import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:nutricook/utils/cloudflare_config.dart';

/// Exception thrown during image upload
class UploadException implements Exception {
  final String message;
  final dynamic originalError;

  UploadException(this.message, [this.originalError]);

  @override
  String toString() => 'UploadException: $message${originalError != null ? '\n$originalError' : ''}';
}

/// Service for uploading images to Cloudflare R2
/// 
/// Handles:
/// - Generating unique filenames
/// - Determining MIME types
/// - AWS Signature v4 authentication
/// - HTTP PUT requests to R2
/// - Returning public URLs
class R2UploadService {
  static const String _algorithm = 'AWS4-HMAC-SHA256';
  static const String _service = 's3';
  static const String _actionType = 'aws4_request';
  static const uuid = Uuid();

  /// Uploads an image file to Cloudflare R2
  /// 
  /// Parameters:
  /// - [imageFile] or [imageXFile]: The image to upload
  /// - [folder]: Folder path in bucket (e.g., 'recipes', 'ingredients', 'users')
  /// - [customFilename]: Optional custom filename (without extension)
  /// 
  /// Returns the public URL of the uploaded image
  /// 
  /// Throws [UploadException] if anything goes wrong
  Future<String> uploadImage({
    File? imageFile,
    XFile? imageXFile,
    required String folder,
    String? customFilename,
  }) async {
    try {
      // Get the file to upload
      final File file;
      if (imageFile != null) {
        file = imageFile;
      } else if (imageXFile != null) {
        file = File(imageXFile.path);
      } else {
        throw UploadException('Either imageFile or imageXFile must be provided');
      }

      // Verify file exists
      if (!await file.exists()) {
        throw UploadException('Image file does not exist');
      }

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Generate object key
      final objectKey = _generateObjectKey(
        folder,
        file.path,
        customFilename,
      );

      // Determine MIME type
      final mimeType = _getMimeType(file.path);
      if (mimeType == null) {
        throw UploadException('Could not determine MIME type for file');
      }

      // Upload to R2
      final uploadUrl = await _uploadToR2(
        objectKey,
        bytes,
        mimeType,
      );

      if (CloudflareConfig.debugMode) {
        debugPrint('[R2] Upload successful: $uploadUrl');
      }

      return uploadUrl;
    } catch (e) {
      if (e is UploadException) rethrow;
      throw UploadException('Failed to upload image', e);
    }
  }

  /// Generates a unique object key for the file
  /// 
  /// Format: {folder}/{uuid}_original_filename.ext
  String _generateObjectKey(
    String folder,
    String filePath,
    String? customFilename,
  ) {
    final originalName = path.basenameWithoutExtension(filePath);
    final extension = path.extension(filePath);
    final fileName = customFilename ?? originalName;
    final uniqueId = uuid.v4().substring(0, 8);
    final objectKey = '$folder/${uniqueId}_$fileName$extension';
    return objectKey;
  }

  /// Determines the MIME type of a file
  String? _getMimeType(String filePath) {
    try {
      return lookupMimeType(filePath) ?? 'application/octet-stream';
    } catch (e) {
      debugPrint('Error determining MIME type: $e');
      return 'application/octet-stream';
    }
  }

  /// Uploads file to R2 using AWS Signature v4
  /// 
  /// Returns the public URL of the uploaded object
  Future<String> _uploadToR2(
    String objectKey,
    List<int> fileBytes,
    String mimeType,
  ) async {
    final now = DateTime.now().toUtc();
    final dateStamp = _formatDate(now);
    final amzDate = _formatAmzDate(now);

    // Calculate payload hash
    final payloadHash = sha256.convert(fileBytes).toString();

    // Prepare headers
    final headers = <String, String>{
      'Host': '${CloudflareConfig.accountId}.r2.cloudflairstorage.com',
      'X-Amz-Content-Sha256': payloadHash,
      'X-Amz-Date': amzDate,
      'Content-Type': mimeType,
    };

    // Create canonical request
    final canonicalRequest = _createCanonicalRequest(
      'PUT',
      '/${CloudflareConfig.bucketName}/$objectKey',
      headers,
      payloadHash,
    );

    // Create string to sign
    final credentialScope = '$dateStamp/$CloudflareConfig.accountId/$_service/$_actionType';
    final canonicalRequestHash = sha256.convert(utf8.encode(canonicalRequest)).toString();
    final stringToSign = '$_algorithm\n$amzDate\n$credentialScope\n$canonicalRequestHash';

    // Calculate signature
    final signature = _calculateSignature(stringToSign, dateStamp);

    // Add authorization header
    final authorizationHeader = _createAuthorizationHeader(
      signature,
      CloudflareConfig.accessKey,
      credentialScope,
      headers,
    );
    headers['Authorization'] = authorizationHeader;

    // Perform upload
    try {
      final uploadUrl = CloudflareConfig.getUploadUrl(objectKey);

      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: headers,
        body: fileBytes,
      ).timeout(
        Duration(minutes: 5),
        onTimeout: () {
          throw UploadException('Upload request timed out');
        },
      );

      if (response.statusCode != 200) {
        throw UploadException(
          'Upload failed with status ${response.statusCode}',
          response.body,
        );
      }

      // Return public URL
      return CloudflareConfig.getPublicUrl(objectKey);
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Network error during upload', e);
    }
  }

  /// Creates canonical request for AWS Signature v4
  String _createCanonicalRequest(
    String method,
    String canonicalUri,
    Map<String, String> headers,
    String payloadHash,
  ) {
    final canonicalHeaders = _createCanonicalHeaders(headers);
    final signedHeaders = _createSignedHeaders(headers);

    return '$method\n'
        '$canonicalUri\n'
        '\n'
        '$canonicalHeaders\n'
        '$signedHeaders\n'
        '$payloadHash';
  }

  /// Creates canonical headers string for AWS signature
  String _createCanonicalHeaders(Map<String, String> headers) {
    final sortedKeys = headers.keys.toList()..sort();
    return sortedKeys
        .map((key) => '${key.toLowerCase()}:${headers[key]}')
        .join('\n');
  }

  /// Creates signed headers string for AWS signature
  String _createSignedHeaders(Map<String, String> headers) {
    final sortedKeys = headers.keys.toList()..sort();
    return sortedKeys.map((key) => key.toLowerCase()).join(';');
  }

  /// Calculates AWS Signature v4
  String _calculateSignature(String stringToSign, String dateStamp) {
    final kDate = Hmac(sha256, utf8.encode('AWS4${CloudflareConfig.secretKey}'))
        .convert(utf8.encode(dateStamp));
    final kRegion = Hmac(sha256, kDate.bytes)
        .convert(utf8.encode(CloudflareConfig.accountId));
    final kService = Hmac(sha256, kRegion.bytes).convert(utf8.encode(_service));
    final kSigning = Hmac(sha256, kService.bytes).convert(utf8.encode(_actionType));
    final signature = Hmac(sha256, kSigning.bytes).convert(utf8.encode(stringToSign));
    return signature.toString();
  }

  /// Creates authorization header for AWS Signature v4
  String _createAuthorizationHeader(
    String signature,
    String accessKey,
    String credentialScope,
    Map<String, String> headers,
  ) {
    final signedHeaders = _createSignedHeaders(headers);
    return '$_algorithm Credential=$accessKey/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';
  }

  /// Formats date for AWS signature (YYYYMMDD)
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}${_pad(dateTime.month)}${_pad(dateTime.day)}';
  }

  /// Formats datetime for AWS signature (YYYYMMDDTHHmmssZ)
  String _formatAmzDate(DateTime dateTime) {
    return '${_formatDate(dateTime)}T'
        '${_pad(dateTime.hour)}${_pad(dateTime.minute)}${_pad(dateTime.second)}Z';
  }

  /// Pads number to 2 digits
  String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }
}
