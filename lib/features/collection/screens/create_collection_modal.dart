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

    if (name.isEmpty) return;

    try {
      setState(() => _isSaving = true);

      if (widget.isEditMode && widget.collectionId != null) {
        await CollectionService().updateCollection(
          collectionId: widget.collectionId!,
          name: name,
          description: description,
          isPublic: _isPublic,
          thumbnailUrl: _thumbnailUrl.isNotEmpty ? _thumbnailUrl : null,
        );
      } else {
        await CollectionService().createCollection(
          name: name,
          description: description,
          isPublic: _isPublic,
          thumbnailUrl: _thumbnailUrl.isNotEmpty ? _thumbnailUrl : null,
        );
      }

      if (!mounted) return;
      widget.onCollectionCreated?.call();
      context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9FA), // Standard page background
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnailSection(),
                  const SizedBox(height: 24),
                  
                  _buildThemedField(
                    label: 'Collection Name',
                    hint: 'e.g. Quick Weeknight Dinners',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildThemedField(
                    label: 'Description (Optional)',
                    hint: 'Tell us what this collection is about...',
                    controller: _descriptionController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('PRIVACY SETTINGS'),
                  const SizedBox(height: 12),
                  _buildPrivacyToggle(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        height: 4,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.rosePink, size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.isEditMode ? 'Edit Collection' : 'New Collection',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44), 
        ],
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return ImageUploadField(
      folder: 'collections',
      label: 'Upload Collection Thumbnail',
      height: 180,
      onSuccess: (url) => setState(() => _thumbnailUrl = url),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: AppColors.rosePink,
      ),
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
        Text(
          label, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.rosePink.withValues(alpha: 0.1), 
                width: 1.5
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.1), 
          width: 1.5
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isPublic ? Icons.public : Icons.lock_outline, 
            color: AppColors.rosePink
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Public Collection', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _isPublic ? 'Visible to everyone' : 'Only visible to you', 
                  style: const TextStyle(fontSize: 11, color: Colors.black54)
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isPublic,
            onChanged: (val) => setState(() => _isPublic = val),
            activeThumbColor: AppColors.rosePink,
            activeTrackColor: AppColors.rosePink.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black12, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(0, 55),
              ),
              child: const Text(
                'CANCEL', 
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900)
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rosePink,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(0, 55),
              ),
              child: Text(
                _isSaving ? 'Saving...' : 'Save Collection',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}