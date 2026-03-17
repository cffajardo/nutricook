import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/archive/providers/archive_provider.dart';
import 'package:nutricook/services/archive_service.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';

class ArchivePage extends ConsumerWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF9FA),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          ),
          title: const Text(
            'Manage Archive',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20),
          ),
          bottom: const TabBar(
            labelColor: AppColors.rosePink,
            unselectedLabelColor: Colors.black45,
            indicatorColor: AppColors.rosePink,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Recipes'),
              Tab(text: 'Collections'),
              Tab(text: 'Ingredients'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ArchivedRecipesList(),
            _ArchivedCollectionsList(),
            _ArchivedIngredientsList(),
          ],
        ),
      ),
    );
  }
}

class _ArchivedRecipesList extends ConsumerWidget {
  const _ArchivedRecipesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedRecipesProvider);

    return archivedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) return _buildEmptyState('recipes');
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ArchiveItemCard(
            title: items[index].name,
            archivedAt: items[index].archivedAt,
            deleteAfter: items[index].deleteAfter,
            onRestore: () => _restoreItem(ref, context, AppConstants.collectionRecipes, items[index].id),
            onDelete: () => _permanentlyDeleteItem(ref, context, AppConstants.collectionRecipes, items[index].id),
          ),
        );
      },
    );
  }
}

class _ArchivedCollectionsList extends ConsumerWidget {
  const _ArchivedCollectionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedCollectionsProvider);

    return archivedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) return _buildEmptyState('collections');
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ArchiveItemCard(
            title: items[index].name,
            archivedAt: items[index].archivedAt,
            deleteAfter: items[index].deleteAfter,
            onRestore: () => _restoreItem(ref, context, AppConstants.collectionCollections, items[index].id),
            onDelete: () => _permanentlyDeleteItem(ref, context, AppConstants.collectionCollections, items[index].id),
          ),
        );
      },
    );
  }
}

class _ArchivedIngredientsList extends ConsumerWidget {
  const _ArchivedIngredientsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedIngredientsProvider);

    return archivedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) return _buildEmptyState('ingredients');
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ArchiveItemCard(
            title: items[index].name,
            archivedAt: items[index].archivedAt,
            deleteAfter: items[index].deleteAfter,
            onRestore: () => _restoreItem(ref, context, AppConstants.collectionIngredients, items[index].id),
            onDelete: () => _permanentlyDeleteItem(ref, context, AppConstants.collectionIngredients, items[index].id),
          ),
        );
      },
    );
  }
}

class _ArchiveItemCard extends StatelessWidget {
  final String title;
  final DateTime? archivedAt;
  final DateTime? deleteAfter;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchiveItemCard({
    required this.title,
    this.archivedAt,
    this.deleteAfter,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final archivedDaysAgo = archivedAt != null 
        ? DateTime.now().difference(archivedAt!).inDays 
        : null;
    
    final daysToDeletion = deleteAfter != null 
        ? deleteAfter!.difference(DateTime.now()).inDays 
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.archive_outlined, size: 14, color: Colors.black45),
              const SizedBox(width: 4),
              Text(
                archivedAt != null 
                    ? 'Archived ${archivedDaysAgo == 0 ? "today" : "$archivedDaysAgo days ago"}'
                    : 'Archived date unknown',
                style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (deleteAfter != null) ...[
                const Icon(Icons.auto_delete_outlined, size: 14, color: AppColors.rosePink),
                const SizedBox(width: 4),
                Text(
                  daysToDeletion! <= 0 ? 'Deleting soon' : 'Deletes in $daysToDeletion days',
                  style: const TextStyle(color: AppColors.rosePink, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ] else ...[
                const Text(
                  'Permanent storage',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRestore,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rosePink,
                    side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.3), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Delete permanently', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildEmptyState(String type) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.archive_rounded, size: 64, color: AppColors.rosePink.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'No archived $type',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black38),
          ),
          const SizedBox(height: 8),
          Text(
            'Items moved to the archive will appear here for restoration or final deletion.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black.withValues(alpha: 0.3)),
          ),
        ],
      ),
    ),
  );
}

Future<void> _restoreItem(WidgetRef ref, BuildContext context, String collection, String docId) async {
  try {
    await ref.read(archiveServiceProvider).restoreItem(
      collection: collection,
      docId: docId,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item restored successfully.')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to restore: $e')),
    );
  }
}

Future<void> _permanentlyDeleteItem(WidgetRef ref, BuildContext context, String collection, String docId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Permanent Delete', style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('This item will be deleted forever. This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text('Delete Forever', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      await ref.read(archiveServiceProvider).permanentlyDeleteItem(
        collection: collection,
        docId: docId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item permanently deleted.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }
}
