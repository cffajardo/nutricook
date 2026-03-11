import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; 
import 'package:nutricook/core/allergen_entries.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/core/widgets/allergen_warning_badge.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/routing/app_routes.dart'; 

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;

  const RecipeCard({
    super.key, 
    required this.recipe, 
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allergenEntries = ref.watch(userAllergenProvider).asData?.value ??
        const <String>[];
    final ingredientsMap = ref.watch(ingredientsMapProvider).asData?.value;
    final allergenLabels = matchedRecipeAllergenLabels(
      recipe: recipe,
      allergenEntries: allergenEntries,
      ingredientsMap: ingredientsMap,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        context.pushNamed(
          AppRoutes.recipeDetailsName,
          extra: recipe,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.14), 
            width: 1.5 
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: const Center(
                      child: Icon(Icons.restaurant, color: AppColors.rosePink, size: 40)
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
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatPill('${recipe.nutritionPerServing?.calories ?? recipe.nutritionTotal?.calories ?? 0} Cal'),
                        _buildStatPill('${recipe.prepTime + recipe.cookTime} min'),
                      ],
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

  Widget _buildStatPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.bold, 
          color: AppColors.rosePink
        ),
      ),
    );
  }
}