import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nutricook/utils/cloudflare_config.dart';

/// Exception thrown during presigned URL generation
class PresignedUrlException implements Exception {
  final String message;
  final dynamic originalError;

  PresignedUrlException(this.message, [this.originalError]);

  @override
  String toString() => 'PresignedUrlException: $message${originalError != null ? '\n$originalError' : ''}';
}

/// Service for requesting pre-signed URLs from the backend
/// 
/// This keeps R2 credentials secure on the server and provides
/// limited-time URLs for uploads (typically 15-30 minutes).
class PresignedUrlService {
  /// Requests a pre-signed URL from the backend for uploading a file to R2
  /// 
  /// Parameters:
  /// - [folder]: Folder path in R2 bucket (e.g., 'recipes', 'ingredients', 'users')
  /// - [fileName]: Original filename with extension
  /// - [mimeType]: MIME type of the file (e.g., 'image/jpeg')
  /// 
  /// Returns: Pre-signed URL valid for uploads
  /// 
  /// Throws [PresignedUrlException] if request fails
  Future<String> getPresignedUrl({
    required String folder,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final url = Uri.parse('${CloudflareConfig.backendApiUrl}/upload/presigned-url');
      
      final payload = {
        'folder': folder,
        'fileName': fileName,
        'mimeType': mimeType,
      };

      if (CloudflareConfig.debugMode) {
        debugPrint('[PresignedUrlService] Requesting URL at: $url');
        debugPrint('[PresignedUrlService] Payload: $payload');
      }

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw PresignedUrlException('Request to backend timed out');
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          final presignedUrl = responseData['presignedUrl'] as String?;
          final uploadUrl = responseData['uploadUrl'] as String?;
          
          if (presignedUrl == null && uploadUrl == null) {
            throw PresignedUrlException(
              'Backend response missing presignedUrl or uploadUrl',
              responseData,
            );
          }

          final finalUrl = presignedUrl ?? uploadUrl!;

          if (CloudflareConfig.debugMode) {
            debugPrint('[PresignedUrlService] Got URL: ${finalUrl.split('?')[0]}...');
          }

          return finalUrl;
        } catch (e) {
          throw PresignedUrlException(
            'Failed to parse backend response: $e',
            response.body,
          );
        }
      } else {
        final errorData = response.body;
        throw PresignedUrlException(
          'Backend returned status ${response.statusCode}',
          errorData,
        );
      }
    } on PresignedUrlException {
      rethrow;
    } catch (e) {
      throw PresignedUrlException('Network error requesting presigned URL', e);
    }
  }
}
