import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/widgets/planner_item_recipe_filter.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_card.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class RecipeCategoryListScreen extends ConsumerStatefulWidget {
  final String category;
  final String subCategoryName;

  const RecipeCategoryListScreen({
    super.key,
    required this.category,
    required this.subCategoryName,
  });

  @override
  ConsumerState<RecipeCategoryListScreen> createState() =>
      _RecipeCategoryListScreenState();
}

class _RecipeCategoryListScreenState
    extends ConsumerState<RecipeCategoryListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            const Divider(height: 1),
            Expanded(child: _buildRecipeGrid(ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.rosePink,
              size: 32,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(
                  widget.subCategoryName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.subCategoryName}...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.rosePink,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.cardRose.withValues(alpha: 0.3),
                  contentPadding: EdgeInsets.zero,
                  // 1.5 width border to match your aesthetic
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: AppColors.rosePink.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: AppColors.rosePink,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
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
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'Filter',
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (context, anim1, anim2) =>
                const PlannerRecipeFilterModal(),
            transitionBuilder: (context, anim1, anim2, child) {
              return SlideTransition(
                position: Tween(
                  begin: const Offset(1, 0),
                  end: const Offset(0, 0),
                ).animate(anim1),
                child: child,
              );
            },
          );
        },
        icon: const Icon(Icons.tune, color: AppColors.rosePink, size: 22),
      ),
    );
  }

  Widget _buildRecipeGrid(WidgetRef ref) {
    final advancedFilters = ref.watch(recipeAdvancedFiltersProvider);

    if (widget.category == 'My Recipes') {
      final userRecipesAsync = ref.watch(userRecipesProvider);
      return userRecipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load recipes: $error')),
        data: (recipes) {
          var filtered = recipes
              .where((recipe) => _matchesQuery(recipe, _searchController.text))
              .toList();

          filtered = applyAdvancedRecipeFilters(filtered, advancedFilters);

          return _buildGrid(filtered);
        },
      );
    }

    final tag = _normalizeTag(widget.subCategoryName);
    final recipesAsync = ref.watch(
      filteredRecipesProvider(
        RecipeFilterInput(query: _searchController.text, tags: <String>[tag]),
      ),
    );

    return recipesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Failed to load recipes: $error')),
      data: (recipes) => _buildGrid(recipes),
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return const Center(child: Text('No recipes found in this category.'));
    }

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
        final recipe = recipes[index];
        return RecipeCard(recipe: recipe);
      },
    );
  }

  bool _matchesQuery(Recipe recipe, String query) {
    if (query.trim().isEmpty) return true;
    final lower = query.toLowerCase();
    return recipe.name.toLowerCase().contains(lower) ||
        recipe.description.toLowerCase().contains(lower) ||
        recipe.ingredients.any(
          (ingredient) => ingredient.name.toLowerCase().contains(lower),
        );
  }

  String _normalizeTag(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '-');
  }
}
