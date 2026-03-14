import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/allergen_entries.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/core/widgets/allergen_warning_badge.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/planner/widgets/planner_item_recipe_filter.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class PlannerRecipeSelectModal extends ConsumerStatefulWidget {
  const PlannerRecipeSelectModal({super.key});

  @override
  ConsumerState<PlannerRecipeSelectModal> createState() =>
      _PlannerRecipeSelectModalState();
}

class _PlannerRecipeSelectModalState
    extends ConsumerState<PlannerRecipeSelectModal> {
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
    final recipesAsync = ref.watch(
      filteredRecipesProvider(RecipeFilterInput(query: _searchController.text)),
    );
    final allergenEntries =
        ref.watch(userAllergenProvider).asData?.value ?? const <String>[];
    final ingredientsMap = ref.watch(ingredientsMapProvider).asData?.value;

    return _KeyboardInsetPadding(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Drag Handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.rosePink,
                      size: 32,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Select Recipe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search recipe...',
                          hintStyle: const TextStyle(color: Colors.black26),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.rosePink,
                          ),
                          filled: true,
                          fillColor: AppColors.cardRose.withValues(alpha: 0.5),
                          contentPadding: EdgeInsets.zero,
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
            ),

            Flexible(
              child: recipesAsync.when(
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
                  return _buildTileView(
                    recipes,
                    allergenEntries,
                    ingredientsMap,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: const Text(
          'Filter',
          style: TextStyle(
            color: AppColors.rosePink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTileView(
    List<Recipe> recipes,
    List<String> allergenEntries,
    Map<String, Ingredient>? ingredientsMap,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.76,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => _buildRecipeCard(
        recipe: recipes[index],
        allergenEntries: allergenEntries,
        ingredientsMap: ingredientsMap,
      ),
    );
  }

  Widget _buildRecipeCard({
    required Recipe recipe,
    required List<String> allergenEntries,
    required Map<String, Ingredient>? ingredientsMap,
  }) {
    final allergenLabels = matchedRecipeAllergenLabels(
      recipe: recipe,
      allergenEntries: allergenEntries,
      ingredientsMap: ingredientsMap,
    );

    final nutritionPerServing =
        recipe.nutritionPerServing ??
        (recipe.nutritionTotal != null && recipe.servings > 0
            ? NutritionCalculator.calculateNutritionPerServing(
                totalNutrition: recipe.nutritionTotal!,
                servings: recipe.servings,
              )
            : null);

    return GestureDetector(
      onTap: () => Navigator.pop(context, <String, dynamic>{
        'id': recipe.id,
        'name': recipe.name,
        'servings': recipe.servings,
        'prepTime': recipe.prepTime,
        'cookTime': recipe.cookTime,
        'thumbnailUrl': recipe.imageURL.isNotEmpty
            ? recipe.imageURL.first
            : null,
        'nutritionPerServing': nutritionPerServing,
        'allergenWarnings': allergenLabels,
      }),
      child: Container(
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
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.cardRose,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        color: AppColors.rosePink,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: AllergenWarningBadge(allergenLabels: allergenLabels),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${nutritionPerServing?.calories ?? 0} Cal • ${recipe.prepTime + recipe.cookTime} min',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                    Text(
                      'Makes ${recipe.servings} servings',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyboardInsetPadding extends StatelessWidget {
  final Widget child;
  const _KeyboardInsetPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: child,
    );
  }
}
