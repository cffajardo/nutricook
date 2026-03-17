import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nutricook/core/allergen_entries.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/core/widgets/allergen_warning_badge.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/routing/app_routes.dart';

class RecipeListItem extends ConsumerWidget {
  final Recipe recipe;

  const RecipeListItem({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allergenEntries = ref.watch(userAllergenProvider).asData?.value ?? const <String>[];
    final ingredientsMap = ref.watch(ingredientsMapProvider).asData?.value;
    final allergenLabels = matchedRecipeAllergenLabels(
      recipe: recipe,
      allergenEntries: allergenEntries,
      ingredientsMap: ingredientsMap,
    );

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.pushNamed(
                AppRoutes.recipeDetailsName,
                extra: recipe,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.cardRose.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.rosePink.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      image: recipe.imageURL.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(recipe.imageURL.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: recipe.imageURL.isEmpty
                        ? const Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.rosePink,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.rosePink.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.prepTime + recipe.cookTime}m',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.rosePink.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.people,
                              size: 14,
                              color: AppColors.rosePink.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.servings} servings',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.rosePink.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        if (allergenLabels.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          AllergenWarningBadge(allergenLabels: allergenLabels),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildCalorieBadge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieBadge() {
    int totalCalories = 0;
    if (recipe.nutritionPerServing != null && recipe.servings > 0) {
      totalCalories = (recipe.nutritionPerServing!.calories * recipe.servings).toInt();
    } else if (recipe.nutritionTotal != null) {
      totalCalories = recipe.nutritionTotal!.calories.toInt();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$totalCalories',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.rosePink,
            ),
          ),
          const Text(
            'Cal',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.rosePink,
            ),
          ),
        ],
      ),
    );
  }
}
