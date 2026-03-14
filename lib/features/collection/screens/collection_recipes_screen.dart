import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/collection_item/collection_item.dart';
import 'package:nutricook/services/collection_service.dart';

class CollectionRecipesScreen extends ConsumerWidget {
  final Collection collection;

  const CollectionRecipesScreen({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA), // System background
      appBar: AppBar(
        title: Text(
          collection.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildRecipesList(),
    );
  }

  Widget _buildRecipesList() {
    return StreamBuilder<List<CollectionItem>>(
      stream: CollectionService().getCollectionItems(collection.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.rosePink, strokeWidth: 3),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardRose,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
                  ),
                  child: const Icon(Icons.restaurant_menu_rounded, size: 48, color: AppColors.rosePink),
                ),
                const SizedBox(height: 24),
                const Text(
                  'NO RECIPES YET',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start adding to ${collection.name}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black26),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildRecipeCard(context, items[index]);
          },
        );
      },
    );
  }

  Widget _buildRecipeCard(BuildContext context, CollectionItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.1),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.go('/recipe/${item.recipeId}');
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 1. Image Placeholder styled like Library Cards
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.cardRose,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.05), width: 1),
                      image: item.thumbnailUrl != null
                          ? DecorationImage(
                              image: NetworkImage(item.thumbnailUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.thumbnailUrl == null
                        ? const Icon(Icons.restaurant_rounded, color: AppColors.rosePink, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // 2. Info Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.recipeName.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildBadge(Icons.timer_outlined, '${item.prepTime + item.cookTime}m'),
                            const SizedBox(width: 8),
                            _buildBadge(Icons.bolt_rounded, '350 cal'), // Mock data for calories
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.black12, size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.rosePink),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.rosePink,
            ),
          ),
        ],
      ),
    );
  }
}