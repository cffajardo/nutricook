import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Service for picking images from camera or gallery
/// 
/// Provides a clean abstraction over ImagePicker for use throughout the app.
/// Handles requesting permissions and returning XFile objects.
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the device gallery
  /// 
  /// Returns null if user cancels the selection
  /// If maxWidth/maxHeight are provided, the image is compressed
  Future<XFile?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 95,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      rethrow;
    }
  }

  /// Picks an image from the device camera
  /// 
  /// Returns null if user cancels the capture
  /// If maxWidth/maxHeight are provided, the image is compressed
  Future<XFile?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 95,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      rethrow;
    }
  }

  /// Picks multiple images from gallery
  /// 
  /// Returns empty list if user cancels
  /// If maxWidth/maxHeight are provided, images are compressed
  Future<List<XFile>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int limit = 10,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 95,
        limit: limit,
      );
      return images;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      rethrow;
    }
  }
}
