import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutricook/services/image_picker_service.dart';
import 'package:nutricook/services/r2_upload_service.dart';

/// Callback when image upload completes successfully
typedef OnImageUploadSuccess = void Function(String imageUrl);

/// Callback when image upload fails
typedef OnImageUploadError = void Function(String error);

/// A reusable image upload field widget
/// 
/// Features:
/// - Tap to upload image via camera or gallery
/// - Shows selected image preview
/// - Upload status indicators (loading, success, error)
/// - Customizable appearance
/// - Error handling and user feedback
/// 
/// Usage:
/// ```dart
/// ImageUploadField(
///   folder: 'recipes',
///   onSuccess: (url) {
///     setState(() => recipeImageUrl = url);
///   },
///   onError: (error) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text('Upload failed: $error'))
///     );
///   },
/// )
/// ```
class ImageUploadField extends StatefulWidget {
  /// Folder in R2 bucket where image will be uploaded
  /// Examples: 'recipes', 'ingredients', 'users'
  final String folder;

  /// Callback when upload is successful
  final OnImageUploadSuccess onSuccess;

  /// Callback when upload fails
  final OnImageUploadError? onError;

  /// Initial/existing image URL to display
  /// If provided, this image is shown as preview
  final String? initialImageUrl;

  /// Custom label for the upload field
  final String label;

  /// Whether to show the label above the field
  final bool showLabel;

  /// Height of the upload area
  final double height;

  /// Width of the upload area
  final double width;

  /// Border radius for the upload area
  final double borderRadius;

  /// Custom image quality (0-100)
  /// Default: 90
  final int imageQuality;

  /// Max width for picked images (resizing)
  /// If null, image is not resized
  final double? maxWidth;

  /// Max height for picked images (resizing)
  /// If null, image is not resized
  final double? maxHeight;

  /// Custom error message display duration
  final Duration errorDuration;

  const ImageUploadField({
    Key? key,
    required this.folder,
    required this.onSuccess,
    this.onError,
    this.initialImageUrl,
    this.label = 'Upload Image',
    this.showLabel = true,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.imageQuality = 90,
    this.maxWidth,
    this.maxHeight,
    this.errorDuration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  late final ImagePickerService _imagePickerService;
  late final R2UploadService _uploadService;

  String? _selectedImagePath;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _imagePickerService = ImagePickerService();
    _uploadService = R2UploadService();
    _uploadedImageUrl = widget.initialImageUrl;
  }

  /// Shows image source selection sheet
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Picks image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      _clearError();
      final pickedFile = await _imagePickerService.pickImageFromCamera(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      if (pickedFile != null) {
        setState(() => _selectedImagePath = pickedFile.path);
        await _uploadImage(pickedFile);
      }
    } catch (e) {
      _showError('Failed to pick image from camera: $e');
    }
  }

  /// Picks image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      _clearError();
      final pickedFile = await _imagePickerService.pickImageFromGallery(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      if (pickedFile != null) {
        setState(() => _selectedImagePath = pickedFile.path);
        await _uploadImage(pickedFile);
      }
    } catch (e) {
      _showError('Failed to pick image from gallery: $e');
    }
  }

  /// Uploads the selected image to R2
  Future<void> _uploadImage(XFile imageFile) async {
    setState(() => _isUploading = true);

    try {
      final imageUrl = await _uploadService.uploadImage(
        imageXFile: imageFile,
        folder: widget.folder,
      );

      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
      });

      widget.onSuccess(imageUrl);
    } catch (e) {
      setState(() => _isUploading = false);
      final errorMsg = 'Upload failed: ${_extractErrorMessage(e)}';
      _showError(errorMsg);
      widget.onError?.call(errorMsg);
    }
  }

  /// Extracts readable error message from exception
  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString();
    }
    return error.toString();
  }

  /// Shows error message
  void _showError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(widget.errorDuration, _clearError);
  }

  /// Clears error message
  void _clearError() {
    if (mounted) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayUrl = _uploadedImageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.showLabel)
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

        // Upload field
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourceSheet,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: _errorMessage != null
                  ? Colors.red.shade50
                  : Colors.grey.shade100,
              border: Border.all(
                color: _errorMessage != null
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Display uploaded image or placeholder
                if (displayUrl != null && !_isUploading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: CachedNetworkImage(
                      imageUrl: displayUrl,
                      fit: BoxFit.cover,
                      width: widget.width,
                      height: widget.height,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported,
                                color: Colors.grey.shade400),
                            SizedBox(height: 8),
                            Text('Failed to load image'),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (!_isUploading)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tap to upload image',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Camera or Gallery',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                // Loading indicator
                if (_isUploading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Uploading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
