import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutricook/services/image_picker_service.dart';
import 'package:nutricook/services/r2_upload_service.dart';

typedef OnImageUploadSuccess = void Function(String imageUrl);

typedef OnImageUploadError = void Function(String error);

class ImageUploadField extends StatefulWidget {
  final String folder;
  final OnImageUploadSuccess? onSuccess;
  final OnImageUploadError? onError;
  final String? initialImageUrl;
  final String label;
  final bool showLabel;
  final double height;
  final double width;
  final double borderRadius;
  final int imageQuality;
  final double? maxWidth;
  final double? maxHeight;
  final Duration errorDuration;
  
  final bool autoUpload;

  const ImageUploadField({
    super.key,
    required this.folder,
    this.onSuccess,
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
    this.autoUpload = false,
  });

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  late final ImagePickerService _imagePickerService;
  late final R2UploadService _uploadService;

  String? _selectedImagePath;
  XFile? _selectedImageFile;
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

  Future<String?> uploadImage() async {
    if (_selectedImageFile == null && _uploadedImageUrl == null) {
      return null;
    }

    if (_selectedImageFile == null) {
      return _uploadedImageUrl;
    }

    setState(() => _isUploading = true);

    try {
      final imageUrl = await _uploadService.uploadImage(
        imageXFile: _selectedImageFile!,
        folder: widget.folder,
      );

      if (!mounted) return null;

      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
        _selectedImageFile = null;
      });

      widget.onSuccess?.call(imageUrl);
      return imageUrl;
    } catch (e) {
      if (!mounted) return null;
      setState(() => _isUploading = false);
      final errorMsg = 'Upload failed: ${_extractErrorMessage(e)}';
      _showError(errorMsg);
      widget.onError?.call(errorMsg);
      return null;
    }
  }

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

  Future<void> _pickImageFromCamera() async {
    try {
      _clearError();
      final pickedFile = await _imagePickerService.pickImageFromCamera(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _selectedImagePath = pickedFile.path;
          _selectedImageFile = pickedFile;
        });
        if (widget.autoUpload) {
          await _uploadImageFile(pickedFile);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to pick image from camera: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      _clearError();
      final pickedFile = await _imagePickerService.pickImageFromGallery(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality: widget.imageQuality,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() {
          _selectedImagePath = pickedFile.path;
          _selectedImageFile = pickedFile;
        });
        if (widget.autoUpload) {
          await _uploadImageFile(pickedFile);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to pick image from gallery: $e');
    }
  }

  Future<void> _uploadImageFile(XFile imageFile) async {
    setState(() => _isUploading = true);

    try {
      final imageUrl = await _uploadService.uploadImage(
        imageXFile: imageFile,
        folder: widget.folder,
      );

      if (!mounted) return;

      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
        _selectedImageFile = null;
      });

      widget.onSuccess?.call(imageUrl);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      final errorMsg = 'Upload failed: ${_extractErrorMessage(e)}';
      _showError(errorMsg);
      widget.onError?.call(errorMsg);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString();
    }
    return error.toString();
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(widget.errorDuration, _clearError);
  }

  void _clearError() {
    if (mounted) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUploadedImage = _uploadedImageUrl != null;
    final hasLocalImage = _selectedImagePath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                if (hasUploadedImage && !_isUploading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: CachedNetworkImage(
                      imageUrl: _uploadedImageUrl!,
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
                else if (hasLocalImage && !hasUploadedImage && !_isUploading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                      width: widget.width,
                      height: widget.height,
                    ),
                  )
                else if (_isUploading)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Uploading...'),
                    ],
                  )
                else
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

                if (_isUploading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
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
