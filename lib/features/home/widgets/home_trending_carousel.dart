import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class HomeTrendingCarousel extends StatelessWidget {
  const HomeTrendingCarousel({
    super.key,
    required this.recipesAsync,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final AsyncValue<List<Recipe>> recipesAsync;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

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
            const Center(
              child: Text(
                'No trending recipes yet',
                style: TextStyle(fontWeight: FontWeight.w600),
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
              return Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _RecipeThumb(
                            imageUrl: recipe.imageURL.isNotEmpty
                                ? recipe.imageURL.first
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              recipe.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recipe.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: recipe.tags
                            .take(3)
                            .map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardRose,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
              );
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

class _RecipeThumb extends StatelessWidget {
  const _RecipeThumb({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl != null && imageUrl!.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        color: AppColors.inputRose,
        child: isNetwork
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.restaurant_menu_rounded),
              )
            : const Icon(Icons.restaurant_menu_rounded, color: Colors.black87),
      ),
    );
  }
}
