import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/collection_item/collection_item.dart';
import 'package:nutricook/services/collection_service.dart';
import 'package:nutricook/features/collection/provider/collection_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_card.dart';
import 'package:nutricook/features/recipe/widgets/recipe_list_item.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class CollectionRecipesScreen extends ConsumerStatefulWidget {
  final Collection collection;

  const CollectionRecipesScreen({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<CollectionRecipesScreen> createState() =>
      _CollectionRecipesScreenState();
}

class _CollectionRecipesScreenState extends ConsumerState<CollectionRecipesScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA), // System background
      appBar: AppBar(
        title: Text(
          widget.collection.name, // Removed toUpperCase()
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Softened from w900
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left, // Unified chevron icon
            color: AppColors.rosePink,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildViewToggleButton(),
          ),
        ],
      ),
      body: _buildRecipesList(),
    );
  }

  Widget _buildViewToggleButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            _isGridView = !_isGridView;
          });
        },
        icon: Icon(
          _isGridView ? Icons.list : Icons.grid_3x3,
          color: AppColors.rosePink,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildRecipesList() {
    final recipesAsync = ref.watch(collectionRecipesProvider(widget.collection.id));

    return recipesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.rosePink,
          strokeWidth: 3,
        ),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardRose.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.rosePink.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 48,
                    color: AppColors.rosePink,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No recipes yet', // Sentence case
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start adding to ${widget.collection.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          );
        }

        if (_isGridView) {
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return RecipeCard(recipe: recipes[index]);
            },
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: recipes.length,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return RecipeListItem(recipe: recipes[index]);
            },
          );
        }
      },
    );
  }
}