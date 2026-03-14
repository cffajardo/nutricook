import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/services/collection_service.dart';

class CollectionDetailModal extends StatefulWidget {
  final Collection collection;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;
  final VoidCallback? onViewRecipes;

  const CollectionDetailModal({
    super.key,
    required this.collection,
    required this.isOwner,
    this.onEdit,
    this.onDelete,
    this.onClose,
    this.onViewRecipes,
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
    final isFavorites = collection.isDefault;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9FA), // System background
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          _buildHeader(isFavorites),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('DETAILS'),
                  const SizedBox(height: 12),
                  _buildDetailCard(),
                  const SizedBox(height: 24),
                  if (isFavorites) _buildFavoritesNotice(),
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
        height: 4, width: 40,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isFavorites) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      collection.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.black87,
                      ),
                    ),
                    if (isFavorites) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.favorite_rounded, color: AppColors.rosePink, size: 20),
                    ]
                  ],
                ),
                Text(
                  collection.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black38),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onClose?.call();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: widget.onViewRecipes,
            child: _buildBrutalistStatCard(
              icon: Icons.restaurant_menu_rounded,
              label: 'RECIPES',
              value: collection.recipeCount.toString(),
              isClickable: widget.onViewRecipes != null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _toggleVisibility,
            child: _buildBrutalistStatCard(
              icon: collection.isPublic ? Icons.public_rounded : Icons.lock_rounded,
              label: 'VISIBILITY',
              value: collection.isPublic ? 'PUBLIC' : 'PRIVATE',
              isClickable: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrutalistStatCard({required IconData icon, required String label, required String value, bool isClickable = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Opacity(
        opacity: isClickable ? 1.0 : 1.0,
        child: Column(
          children: [
            Icon(icon, color: AppColors.rosePink, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black26)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.rosePink),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Collection Name', collection.name),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          _buildInfoRow('Description', collection.description),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black87)),
      ],
    );
  }

  Widget _buildFavoritesNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.rosePink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.rosePink, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is your default collection for all the recipes you love.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.rosePink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final showEditActions = widget.isOwner && !collection.isDefault;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: showEditActions
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onEdit?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black12, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('EDIT', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showDeleteConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosePink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('CLOSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('DELETE COLLECTION?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to delete "${collection.name}"? This action is permanent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVisibility() async {
    try {
      final newIsPublic = !collection.isPublic;
      await CollectionService().updateCollection(
        collectionId: collection.id,
        isPublic: newIsPublic,
      );
      setState(() {
        collection = collection.copyWith(isPublic: newIsPublic);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Collection is now ${newIsPublic ? "PUBLIC" : "PRIVATE"}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update visibility: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}