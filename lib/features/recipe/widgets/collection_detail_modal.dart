import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/collection/collection.dart';

class CollectionDetailModal extends StatefulWidget {
  final Collection collection;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;

  const CollectionDetailModal({
    super.key,
    required this.collection,
    required this.isOwner,
    this.onEdit,
    this.onDelete,
    this.onClose,
  });

  @override
  State<CollectionDetailModal> createState() => _CollectionDetailModalState();
}

class _CollectionDetailModalState extends State<CollectionDetailModal> {
  late Collection collection;

  @override
  void initState() {
    super.initState();
    collection = widget.collection;
  }

  @override
  Widget build(BuildContext context) {
    final isFavoritesCollection = collection.isDefault;

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
          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              collection.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (isFavoritesCollection)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: AppColors.rosePink,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.onClose?.call();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.collections_bookmark,
                          label: 'Recipes',
                          value: collection.recipeCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: collection.isPublic
                              ? Icons.public
                              : Icons.lock_outline,
                          label: 'Visibility',
                          value: collection.isPublic ? 'Public' : 'Private',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Info section
                  Text(
                    'Collection Info',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    label: 'Name',
                    value: collection.name,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoTile(
                    label: 'Description',
                    value: collection.description,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoTile(
                    label: 'Type',
                    value: isFavoritesCollection
                        ? 'Favorites (Default)'
                        : (collection.isPublic ? 'Public' : 'Private'),
                  ),
                  const SizedBox(height: 16),
                  if (collection.isDefault)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.rosePink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.rosePink.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        '❤️ Your Favorites collection is special - save your favorite recipes here!',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.rosePink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Action buttons
          if (widget.isOwner && !collection.isDefault)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEdit?.call();
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.rosePink),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showDeleteConfirmation(),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (!widget.isOwner)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.rosePink,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ),
            )
          else
            const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rosePink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.rosePink, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.rosePink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Collection?'),
        content: Text(
          'Are you sure you want to delete "${collection.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
