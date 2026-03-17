import 'package:flutter_dotenv/flutter_dotenv.dart';


class CloudflareConfig {
  static String get accountId {
    final value = dotenv.env['CLOUDFLARE_ACCOUNT_ID'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('CLOUDFLARE_ACCOUNT_ID not configured in .env');
    }
    return value;
  }

  static String get bucketName {
    final value = dotenv.env['CLOUDFLARE_BUCKET_NAME'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('CLOUDFLARE_BUCKET_NAME not configured in .env');
    }
    return value;
  }

  static String get accessKeyId {
    final value = dotenv.env['CLOUDFLARE_ACCESS_KEY_ID'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('CLOUDFLARE_ACCESS_KEY_ID not configured in .env');
    }
    return value;
  }

  static String get secretAccessKey {
    final value = dotenv.env['CLOUDFLARE_SECRET_ACCESS_KEY'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('CLOUDFLARE_SECRET_ACCESS_KEY not configured in .env');
    }
    return value;
  }

  static String get publicUrl {
    final value = dotenv.env['CLOUDFLARE_PUBLIC_URL'];
    if (value == null || value.isEmpty) {
      throw ConfigurationException('CLOUDFLARE_PUBLIC_URL not configured in .env');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  /// Debug mode flag
  static bool get debugMode {
    final value = dotenv.env['DEBUG_MODE']?.toLowerCase();
    return value == 'true' || value == '1';
  }

  static String get s3Endpoint {
    final customEndpoint = dotenv.env['CLOUDFLARE_S3_ENDPOINT'];
    if (customEndpoint != null && customEndpoint.isNotEmpty) {
      return customEndpoint;
    }
    
    final id = accountId; 
    if (id.isEmpty) {
      throw ConfigurationException('Account ID is empty');
    }
    String endpoint = 'https://$id.r2.cloudflarestorage.com';
    // Ensure we return a clean base endpoint without trailing slashes or bucket names
    return endpoint.replaceAll(RegExp(r'/+$'), '');
  }

  static String getUploadUrl(String objectKey) {
    // Ensure endpoint doesn't have the bucket name or trailing slash
    final bucket = bucketName;
    final endpoint = s3Endpoint.replaceAll(RegExp('/$bucket\$'), '').replaceAll(RegExp(r'/+$'), '');
    
    if (bucket.isEmpty) {
      throw ConfigurationException('Bucket name is empty');
    }
    final cleanKey = objectKey.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    return '$endpoint/$bucket/$cleanKey';
  }

  static String getPublicUrl(String objectKey) {
    return '$publicUrl/$objectKey';
  }
}

class ConfigurationException implements Exception {
  final String message;

  ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
