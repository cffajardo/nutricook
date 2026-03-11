import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/widgets/planner_item_recipe_filter.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_card.dart';
import 'package:nutricook/routing/app_routes.dart';

class RecipeMainScreen extends ConsumerStatefulWidget {
  const RecipeMainScreen({super.key});

  @override
  ConsumerState<RecipeMainScreen> createState() => _RecipeMainScreenState();
}

class _RecipeMainScreenState extends ConsumerState<RecipeMainScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    return Container(
      color: const Color(0xFFFFF9FA), // Unified pink tint
      child: SafeArea(
        bottom: false, // Prevents gap above NavBar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            _buildCategoryPills(),
            Expanded(child: _buildDiscoveryFeed(ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        const Text(
          'Recipes', 
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
        ),
        
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.rosePink.withValues(alpha: 0.2), 
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: () {
              context.pushNamed(AppRoutes.recipeCreateName);
            },
            icon: const Icon(
              Icons.add_rounded, 
              color: AppColors.rosePink, 
              size: 28,
            ),
            tooltip: 'Create Recipe',
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search ingredients...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.rosePink),
                  filled: true,
                  fillColor: AppColors.cardRose.withValues(alpha: 0.3),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
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
    return IconButton(
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, anim1, anim2) => const PlannerRecipeFilterModal(),
          transitionBuilder: (context, anim1, anim2, child) {
            return SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(anim1),
              child: child,
            );
          },
        );
      },
      icon: const Icon(Icons.tune, color: AppColors.rosePink),
      style: IconButton.styleFrom(
        side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.2), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCategoryPills() {
    final categories = ['Cuisine', 'Nutrition', 'Dietary', 'Difficulty', 'Custom'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ActionChip(
              onPressed: () {
                    final tappedCategory = categories[index];
                    if (tappedCategory == 'Custom') {
                      context.pushNamed(AppRoutes.userCustomRecipesName);
                    } else {
                      context.pushNamed(
                        AppRoutes.subCategoryName,
                        pathParameters: {'category': tappedCategory},
                      );
                    }
                  },
              label: Text(categories[index]),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.2), width: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscoveryFeed(WidgetRef ref) {
    final recipesAsync = ref.watch(
      filteredRecipesProvider(
        RecipeFilterInput(query: _searchController.text),
      ),
    );

    return recipesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load recipes: $error'),
        ),
      ),
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(child: Text('No recipes found.'));
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
      },
    );
  }
}