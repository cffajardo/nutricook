import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/providers/library_catalog_provider.dart';
import 'package:nutricook/features/admin/providers/create_ingredient_provider.dart';
import 'package:nutricook/features/admin/screens/edit_ingredient_screen.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';

class LibrarySingleItemDetailScreen extends ConsumerWidget {
  const LibrarySingleItemDetailScreen({
    super.key,
    required this.categoryId,
    required this.itemId,
  });

  final String categoryId;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      libraryItemDetailProvider(
        LibraryItemDetailQuery(categoryId: categoryId, itemId: itemId),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 22,
          ),
        ),
        actions: detailAsync.value?.isCustom == true
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.rosePink),
                  onPressed: () async {
                    final ingredient = await ref.read(ingredientByIdProvider(itemId).future);
                    if (ingredient != null && context.mounted) {
                      ref.read(createIngredientProvider.notifier).populateFromIngredient(ingredient);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditIngredientScreen(ingredientId: itemId),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmation(context, ref),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Failed to load details: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return const Center(
              child: Text(
                'Item not found.',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroVisual(detail.imageUrl),
                const SizedBox(height: 18),
                Text(
                  detail.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSectionCard(
                  title: 'Description',
                  child: Text(
                    detail.description,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                if (detail.fields.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildSectionCard(
                    title: 'Details',
                    child: Column(
                      children: [
                        for (final field in detail.fields)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      field.label,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      field.value,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroVisual(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.cardRose.withValues(alpha: 0.35),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imageUrl != null && imageUrl.trim().isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.rosePink,
                    size: 48,
                  ),
                ),
              )
            : const Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.rosePink,
                  size: 52,
                ),
              ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.15),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.rosePink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Ingredient', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this ingredient? This action will archive it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref.read(createIngredientProvider.notifier).deleteIngredient(itemId);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext); // Close dialog
              }
              if (success && context.mounted) {
                context.pop(); // Use go_router pop to go back to list safely
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingredient deleted'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
