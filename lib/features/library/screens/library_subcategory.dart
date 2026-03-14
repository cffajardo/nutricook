import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/library_constants.dart';
import 'package:nutricook/features/library/providers/library_catalog_provider.dart';
import 'package:nutricook/features/library/screens/custom_ingredients_screen.dart';

class LibrarySubCategoryScreen extends ConsumerWidget {
  final String categoryId;

  const LibrarySubCategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = libraryCategoryById(categoryId);
    final subCategories = ref.watch(librarySubCategoriesProvider(categoryId));
    final title = category?.label ?? 'Library';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: subCategories.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: subCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 32,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final item = subCategories[index];
                return _buildSubCategoryCard(context, item: item);
              },
            ),
    );
  }

  Widget _buildSubCategoryCard(
    BuildContext context, {
    required LibrarySubCategoryDef item,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to CustomIngredientsScreen for custom category
        if (item.id == LibrarySubCategoryIds.custom) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomIngredientsScreen(),
            ),
          );
        } else {
          // Navigate to regular library item screen for other categories
          context.push('/library/$categoryId/${item.id}');
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardRose.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.rosePink.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(item.icon, size: 48, color: AppColors.rosePink),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No subcategories found.',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.black26,
          fontSize: 18,
        ),
      ),
    );
  }
}
