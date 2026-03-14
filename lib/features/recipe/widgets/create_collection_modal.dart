import 'package:flutter/material.dart';
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
      _showMessage('Collection name is required.');
      return;
    }

    try {
      setState(() => _isSaving = true);

      if (widget.isEditMode && widget.collectionId != null) {
        // Update existing collection
        await CollectionService().updateCollection(
          collectionId: widget.collectionId!,
          name: name,
          description: description,
          isPublic: _isPublic,
          thumbnailUrl: _thumbnailUrl.isNotEmpty ? _thumbnailUrl : null,
        );
        _showMessage('Collection updated.');
      } else {
        // Create new collection
        await CollectionService().createCollection(
          name: name,
          description: description,
          isPublic: _isPublic,
          thumbnailUrl: _thumbnailUrl.isNotEmpty ? _thumbnailUrl : null,
        );
        _showMessage('Collection created.');
      }

      if (!mounted) return;
      widget.onCollectionCreated?.call();
      Navigator.pop(context);
    } catch (error) {
      _showMessage('Failed to save collection: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isEditMode ? 'Edit Collection' : 'Create Collection';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageUploadField(
                    folder: 'collections',
                    label: 'Upload Collection Thumbnail (Optional)',
                    height: 160,
                    onSuccess: (imageUrl) {
                      setState(() => _thumbnailUrl = imageUrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thumbnail uploaded successfully'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onError: (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Upload failed: $error'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildFormField(
                    label: 'Collection Name',
                    controller: _nameController,
                    hint: 'e.g., Quick Weeknight Meals',
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Description',
                    controller: _descriptionController,
                    hint: 'What is this collection for?',
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  _buildPrivacyToggle(),
                  const SizedBox(height: 16),
                  Text(
                    _isPublic
                        ? 'This collection will be visible to other users'
                        : 'This collection is private - only visible to you',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.rosePink),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.rosePink),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.rosePink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _isSaving ? 'Saving...' : 'Save Collection',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.rosePink.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.rosePink.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildPrivacyToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: SwitchListTile.adaptive(
        title: const Text(
          'Make Public',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Allow other users to discover this collection',
          style: TextStyle(fontSize: 12),
        ),
        value: _isPublic,
        activeThumbColor: AppColors.rosePink,
        onChanged: (value) => setState(() => _isPublic = value),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
