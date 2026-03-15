import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    collection = widget.collection;
  }

  @override
  Widget build(BuildContext context) {
    final isFavorites = collection.isDefault;
    final bool canEdit = widget.isOwner && !collection.isDefault;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.6,
      maxChildSize: 0.98,
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
              _buildHeader(canEdit),
              const Divider(height: 1),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildOverviewSection(isFavorites),
                    const SizedBox(height: 32),
                    _buildDetailsSection(),
                    const SizedBox(height: 32),
                    if (isFavorites) ...[
                      _buildFavoritesNotice(),
                      const SizedBox(height: 32),
                    ],
                    if (canEdit) ...[
                      const SizedBox(height: 8),
                      _buildDeleteButton(),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool canEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              widget.onClose?.call();
              context.pop();
            },
            icon: const Icon(
              Icons.chevron_left, // Changed to chevron_left
              color: AppColors.rosePink,
              size: 32, // Size adjusted to match PlannerItemEditModal
            ),
          ),
          const Text(
            'Collection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (canEdit)
            TextButton(
              onPressed: () {
                context.pop();
                widget.onEdit?.call();
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rosePink,
                ),
              ),
            )
          else
            const SizedBox(width: 64),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(bool isFavorites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle(title: 'Overview'),
            if (isFavorites) ...[
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Icon(Icons.favorite_rounded, color: AppColors.rosePink, size: 20),
              ),
            ]
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatPill(
                icon: Icons.restaurant_menu_rounded,
                label: 'Recipes',
                value: collection.recipeCount.toString(),
                onTap: widget.onViewRecipes,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatPill(
                icon: collection.isPublic ? Icons.public_rounded : Icons.lock_rounded,
                label: 'Visibility',
                value: collection.isPublic ? 'Public' : 'Private',
                isLoading: _isUpdating,
                onTap: widget.isOwner && !isFavorites ? _toggleVisibility : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
        child: isLoading
            ? const Center(
                child: SizedBox(
                  height: 62,
                  width: 24,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.rosePink,
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Icon(icon, color: AppColors.rosePink, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'About'),
        _buildInputGroup([
          _buildStaticContentRow('Name', collection.name),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildStaticContentRow(
            'Description',
            collection.description.isEmpty ? 'No description provided.' : collection.description,
          ),
        ]),
      ],
    );
  }

  Widget _buildFavoritesNotice() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.auto_awesome, color: AppColors.rosePink),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your Favorites collection is automatically synced across all your devices.',
              style: TextStyle(fontSize: 14.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: _showDeleteConfirmation,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3), width: 1.5),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Delete Collection',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(List<Widget> children) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildStaticContentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.rosePink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Collection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${collection.name}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14.5, height: 1.35),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
              widget.onDelete?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVisibility() async {
    setState(() => _isUpdating = true);
    try {
      final newStatus = !collection.isPublic;
      await CollectionService().updateCollection(
          collectionId: collection.id, isPublic: newStatus);
      setState(() => collection = collection.copyWith(isPublic: newStatus));

      if (!mounted) return;
      final rootMessenger = ScaffoldMessenger.of(
        Navigator.of(context, rootNavigator: true).context,
      );
      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? 'Collection is now public.' : 'Collection is now private.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update visibility: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
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