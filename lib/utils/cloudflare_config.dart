import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for Cloudflare R2 settings
/// 
/// This class loads credentials and configuration from .env file.
/// Never commit .env to version control - use .env.example instead.
class CloudflareConfig {
  /// R2 Account ID - found in Cloudflare dashboard
  static String get accountId {
    final value = dotenv.env['R2_ACCOUNT_ID'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('R2_ACCOUNT_ID not configured in .env');
    }
    return value;
  }

  /// R2 API Access Key
  static String get accessKey {
    final value = dotenv.env['R2_ACCESS_KEY'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('R2_ACCESS_KEY not configured in .env');
    }
    return value;
  }

  /// R2 API Secret Key
  static String get secretKey {
    final value = dotenv.env['R2_SECRET_KEY'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('R2_SECRET_KEY not configured in .env');
    }
    return value;
  }

  /// R2 Bucket Name
  static String get bucketName {
    final value = dotenv.env['R2_BUCKET_NAME'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('R2_BUCKET_NAME not configured in .env');
    }
    return value;
  }

  /// Public URL for accessing uploaded images (CDN or R2 endpoint)
  static String get publicUrl {
    final value = dotenv.env['R2_PUBLIC_URL'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('R2_PUBLIC_URL not configured in .env');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  /// Debug mode flag
  static bool get debugMode {
    final value = dotenv.env['DEBUG_MODE']?.toLowerCase();
    return value == 'true' || value == '1';
  }

  /// Constructs the S3-compatible endpoint URL for R2
  /// Format: https://{accountId}.r2.cloudflairstorage.com
  static String get s3Endpoint {
    return 'https://${accountId}.r2.cloudflairstorage.com';
  }

  /// Constructs the upload URL for a specific object in R2
  /// Used for PUT requests
  static String getUploadUrl(String objectKey) {
    return '$s3Endpoint/$bucketName/$objectKey';
  }

  /// Constructs the public-facing URL for an uploaded object
  /// Used for displaying images to users
  static String getPublicUrl(String objectKey) {
    return '$publicUrl/$objectKey';
  }
}

/// Exception thrown when configuration is missing or invalid
class ConfigurationException implements Exception {
  final String message;

  ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
