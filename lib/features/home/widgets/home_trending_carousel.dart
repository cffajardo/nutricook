import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/allergen_entries.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/core/widgets/allergen_warning_badge.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class HomeTrendingCarousel extends StatelessWidget {
  const HomeTrendingCarousel({
    super.key,
    required this.recipesAsync,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    this.emptyMessage = 'No trending recipes yet',
  });

  final AsyncValue<List<Recipe>> recipesAsync;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return recipesAsync.when(
      loading: () => _buildShell(
        context,
        const Center(
          child: CircularProgressIndicator(color: AppColors.rosePink),
        ),
        count: 3,
      ),
      error: (err, _) => _buildShell(
        context,
        const Center(
          child: Text(
            'Unable to load trending recipes',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        count: 1,
      ),
      data: (recipes) {
        final top = recipes.take(5).toList(growable: false);
        if (top.isEmpty) {
          return _buildShell(
            context,
            Center(
              child: Text(
                emptyMessage,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            count: 1,
          );
        }

        return _buildShell(
          context,
          PageView.builder(
            controller: pageController,
            itemCount: top.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final recipe = top[index];
              return _RecipeStackCard(recipe: recipe);
            },
          ),
          count: top.length,
        );
      },
    );
  }

  Widget _buildShell(BuildContext context, Widget child, {required int count}) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: AppColors.cardRose,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(count, (index) {
                final active = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.rosePink : Colors.black26,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeStackCard extends ConsumerWidget {
  const _RecipeStackCard({required this.recipe});

  final Recipe recipe;

  String _formatLikesCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = recipe.ownerId;
    final ownerAsync = ownerId == null
        ? const AsyncValue<Map<String, dynamic>?>.data(null)
        : ref.watch(userDataByIdProvider(ownerId));

    final username = ownerAsync.asData?.value?['username']?.toString();
    final allergenEntries = ref.watch(userAllergenProvider).asData?.value ??
        const <String>[];
    final ingredientsMap = ref.watch(ingredientsMapProvider).asData?.value;
    final allergenLabels = matchedRecipeAllergenLabels(
      recipe: recipe,
      allergenEntries: allergenEntries,
      ingredientsMap: ingredientsMap,
    );
    final calories =
        recipe.nutritionPerServing?.calories ?? recipe.nutritionTotal?.calories;
    final imageUrl = recipe.imageURL.isNotEmpty ? recipe.imageURL.first : null;
    final isNetwork = imageUrl != null && imageUrl.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          context.pushNamed(AppRoutes.recipeDetailsName, extra: recipe);
        },
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.18),
              width: 1.3,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isNetwork)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, url, error) {
                      debugPrint('[Image Load] URL: $imageUrl');
                      debugPrint('[Image Load] Error: $error');
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported, color: Colors.red),
                            SizedBox(height: 8),
                            Text('Failed to load image', textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                _fallbackBg(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: AllergenWarningBadge(allergenLabels: allergenLabels),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (calories != null)
                          Text(
                            '$calories Cal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (calories != null)
                          Text(
                            '  •  ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatLikesCount(recipe.favoriteCount),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '  •  ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            username == null || username.isEmpty
                                ? '@unknown'
                                : '@$username',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackBg() {
    return Container(
      color: AppColors.cardRose,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant_menu_rounded,
        size: 38,
        color: Colors.black45,
      ),
    );
  }
}
