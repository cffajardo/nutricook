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

class UploadException implements Exception {
  final String message;
  final dynamic originalError;

  UploadException(this.message, [this.originalError]);

  @override
  String toString() => 'UploadException: $message${originalError != null ? '\n$originalError' : ''}';
}

class R2UploadService {
  static const uuid = Uuid();
  static const _awsAlgorithm = 'AWS4-HMAC-SHA256';
  static const _awsService = 's3';
  static const _awsTerminator = 'aws4_request';

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

  String? _getMimeType(String filePath) {
    try {
      return lookupMimeType(filePath) ?? 'application/octet-stream';
    } catch (e) {
      debugPrint('Error determining MIME type: $e');
      return 'application/octet-stream';
    }
  }

  Future<String> _uploadToR2(
    String objectKey,
    List<int> fileBytes,
    String mimeType,
  ) async {
    try {
      final bucket = CloudflareConfig.bucketName;
      final uploadUrl = CloudflareConfig.getUploadUrl(objectKey);
      final cleanObjectKey = objectKey.trim().replaceAll(RegExp(r'^/+|/+$'), '');
      
      if (CloudflareConfig.debugMode) {
        debugPrint('[R2] Constructed upload URL: $uploadUrl');
      }

      try {
        Uri.parse(uploadUrl);
      } catch (e) {
        throw UploadException('Invalid upload URL: $uploadUrl', e);
      }

      final now = DateTime.now().toUtc();
      final amzDate = _formatAmzDate(now);
      final dateStamp = _formatDateStamp(now);

      final payloadHash = sha256.convert(fileBytes).toString();
      final canonicalRequest = _createCanonicalRequest(
        bucket: bucket,
        objectKey: cleanObjectKey,
        amzDate: amzDate,
        payloadHash: payloadHash,
        mimeType: mimeType,
      );

      final credentialScope = '$dateStamp/auto/$_awsService/$_awsTerminator';
      final canonicalRequestHash = sha256.convert(utf8.encode(canonicalRequest)).toString();
      final stringToSign = '$_awsAlgorithm\n$amzDate\n$credentialScope\n$canonicalRequestHash';

      final signature = _calculateSignature(
        stringToSign,
        dateStamp,
      );

      final authorizationHeader = _buildAuthorizationHeader(
        amzDate,
        dateStamp,
        signature,
      );

      // Build headers for request
      final headers = <String, String>{
        'Content-Type': mimeType,
        'X-Amz-Date': amzDate,
        'Authorization': authorizationHeader,
        'X-Amz-Content-Sha256': payloadHash,
      };

      if (CloudflareConfig.debugMode) {
        debugPrint('[R2] Uploading ${fileBytes.length} bytes to $objectKey');
        debugPrint('[R2] Upload URL: $uploadUrl');
        debugPrint('[R2] Request Headers:');
        headers.forEach((key, value) {
          if (key == 'Authorization') {
            debugPrint('[R2]   $key: ${value.substring(0, 50)}...');
          } else if (key == 'X-Amz-Content-Sha256') {
            debugPrint('[R2]   $key: ${value.substring(0, 20)}...');
          } else {
            debugPrint('[R2]   $key: $value');
          }
        });
      }

      // Perform upload
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: headers,
        body: fileBytes,
      ).timeout(
        const Duration(minutes: 5),
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

      final publicUrl = CloudflareConfig.getPublicUrl(cleanObjectKey);
      if (CloudflareConfig.debugMode) {
        debugPrint('[R2] Public URL for image: $publicUrl');
      }
      return publicUrl;
    } on UploadException {
      rethrow;
    } catch (e) {
      throw UploadException('Network error during upload', e);
    }
  }

  String _createCanonicalRequest({
    required String bucket,
    required String objectKey,
    required String amzDate,
    required String payloadHash,
    required String mimeType,
  }) {
    final endpoint = CloudflareConfig.s3Endpoint;
    final canonicalUri = '/$bucket/$objectKey';
    const canonicalQuerystring = '';
    
    final hostHeader = Uri.parse(endpoint).host;
    final canonicalHeaders = 
        'content-type:$mimeType\n'
        'host:$hostHeader\n'
        'x-amz-content-sha256:$payloadHash\n'
        'x-amz-date:$amzDate\n';
    
    const signedHeaders = 'content-type;host;x-amz-content-sha256;x-amz-date';
    
    if (CloudflareConfig.debugMode) {
      debugPrint('[R2] Canonical Request Components:');
      debugPrint('[R2] - Method: PUT');
      debugPrint('[R2] - URI: $canonicalUri');
      debugPrint('[R2] - Host Header: $hostHeader');
      debugPrint('[R2] - Payload Hash: $payloadHash');
    }
    
    return 'PUT\n$canonicalUri\n$canonicalQuerystring\n$canonicalHeaders\n$signedHeaders\n$payloadHash';
  }

  /// Calculates the AWS Signature V4
  String _calculateSignature(
    String stringToSign,
    String dateStamp,
  ) {
    // kDate = HMAC-SHA256("AWS4" + secretAccessKey, date)
    final kDate = Hmac(sha256, utf8.encode('AWS4${CloudflareConfig.secretAccessKey}'))
        .convert(utf8.encode(dateStamp));

    // kRegion = HMAC-SHA256(kDate, "auto") 
    final kRegion = Hmac(sha256, kDate.bytes)
        .convert(utf8.encode('auto'));

    // kService = HMAC-SHA256(kRegion, "s3")
    final kService = Hmac(sha256, kRegion.bytes)
        .convert(utf8.encode('s3'));

    // kSigning = HMAC-SHA256(kService, "aws4_request")
    final kSigning = Hmac(sha256, kService.bytes)
        .convert(utf8.encode('aws4_request'));

    // Signature = Hex(HMAC-SHA256(kSigning, stringToSign))
    final signature = Hmac(sha256, kSigning.bytes)
        .convert(utf8.encode(stringToSign));

    return signature.toString();
  }

  String _buildAuthorizationHeader(
    String amzDate,
    String dateStamp,
    String signature,
  ) {
    final credentialScope = '$dateStamp/auto/$_awsService/$_awsTerminator';
    const signedHeaders = 'content-type;host;x-amz-content-sha256;x-amz-date';
    
    return '$_awsAlgorithm Credential=${CloudflareConfig.accessKeyId}/$credentialScope, '
        'SignedHeaders=$signedHeaders, Signature=$signature';
  }

  String _formatAmzDate(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$year$month${day}T$hour$minute${second}Z';
  }

  String _formatDateStamp(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }
}

