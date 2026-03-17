import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/services/collection_service.dart';
import 'package:nutricook/widgets/image_upload_field.dart';

class CreateCollectionModal extends StatefulWidget {
  final VoidCallback? onCollectionCreated;
  final bool isEditMode;
  final String? collectionId;
  final String? initialName;
  final String? initialDescription;
  final bool? initialIsPublic;

  const CreateCollectionModal({
    super.key,
    this.onCollectionCreated,
    this.isEditMode = false,
    this.collectionId,
    this.initialName,
    this.initialDescription,
    this.initialIsPublic,
  });

  @override
  State<CreateCollectionModal> createState() => _CreateCollectionModalState();
}

class _CreateCollectionModalState extends State<CreateCollectionModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isPublic = false;
  bool _isSaving = false;
  String _thumbnailUrl = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _isPublic = widget.initialIsPublic ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a collection name.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);

      if (widget.isEditMode && widget.collectionId != null) {
        CollectionService().updateCollection(
          collectionId: widget.collectionId!,
          name: name,
          description: description,
          isPublic: _isPublic,
          thumbnailUrl: _thumbnailUrl.isNotEmpty ? _thumbnailUrl : null,
        );
      } else {
        CollectionService().createCollection(
          name: name,
          description: description,
          isPublic: _isPublic,
          thumbnailUrl: _thumbnailUrl.isNotEmpty ? _thumbnailUrl : null,
        );
      }

      widget.onCollectionCreated?.call();
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
        return Container(
          padding: EdgeInsets.only(bottom: keyboardInset),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const _DragHandle(),
              _buildHeader(),
              const Divider(height: 1),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildThumbnailSection(),
                    const SizedBox(height: 32),
                    
                    _buildThemedField(
                      label: 'Name',
                      hint: 'e.g. Quick Weeknight Dinners',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 32),
                    
                    _buildThemedField(
                      label: 'Description',
                      hint: 'Tell us what this collection is about...',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                    
                    _buildPrivacySection(),
                    const SizedBox(height: 40),
                    
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.rosePink,
              size: 32,
            ),
          ),
          Text(
            widget.isEditMode ? 'Edit Collection' : 'New Collection',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.rosePink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return ImageUploadField(
      folder: 'collections',
      label: 'Upload Thumbnail',
      height: 180,
      onSuccess: (url) => setState(() => _thumbnailUrl = url),
    );
  }

  Widget _buildThemedField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: label),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26),
            filled: true,
            fillColor: AppColors.cardRose.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: AppColors.rosePink.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.rosePink,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Privacy'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.rosePink.withValues(alpha: 0.14),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _isPublic ? Icons.public : Icons.lock_outline,
                color: AppColors.rosePink,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Public Collection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPublic ? 'Visible to everyone' : 'Only visible to you',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _isPublic,
                onChanged: (val) => setState(() => _isPublic = val),
                activeColor: Colors.white,
                activeTrackColor: AppColors.rosePink,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.black12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Collection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.rosePink,
        ),
      ),
    );
  }
}