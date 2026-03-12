import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/routing/app_routes.dart';

class RecipeViewAbout extends ConsumerWidget {
  final Recipe recipe;
  const RecipeViewAbout({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = recipe.ownerId;
    final currentUserId = ref.watch(currentUserIdProvider);
    final ownerDataAsync = ownerId == null
        ? const AsyncValue<Map<String, dynamic>?>.data(null)
        : ref.watch(userDataByIdProvider(ownerId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 50,
                    color: Colors.black12,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _FavoriteButton(recipe: recipe),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      _buildMiniStat('Prep Time', '${recipe.prepTime} min'),
                      const SizedBox(width: 20),
                      _buildMiniStat('Cook Time', '${recipe.cookTime} min'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildInfoBox('Nutritional Info', _nutritionText(recipe)),

          const SizedBox(height: 20),

          _buildInfoBox(
            'Created By',
            ownerDataAsync.when(
              loading: () => 'Loading creator...',
              error: (_, _) => 'Unknown creator',
              data: (ownerData) =>
                  (ownerData?['username'] ?? ownerId ?? 'Unknown creator')
                      .toString(),
            ),
            trailing: ownerId == null
                ? null
                : TextButton.icon(
                    onPressed: () {
                      if (ownerId == currentUserId) {
                        context.goNamed(AppRoutes.profileName);
                        return;
                      }

                      context.pushNamed(
                        AppRoutes.profileUserName,
                        pathParameters: {'userId': ownerId},
                      );
                    },
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: const Text('View Profile'),
                  ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.description,
                  style: const TextStyle(color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. TAGS ROW
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Row(
              children: const [
                Icon(Icons.local_offer_outlined, size: 16),
                SizedBox(width: 8),
                Text(
                  'Tags',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (recipe.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recipe.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.cardRose.withValues(
                            alpha: 0.3,
                          ),
                          side: BorderSide(
                            color: AppColors.rosePink.withValues(alpha: 0.2),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  String _nutritionText(Recipe recipe) {
    final nutrition = recipe.nutritionPerServing ?? recipe.nutritionTotal;
    if (nutrition == null) {
      return 'Nutrition info unavailable';
    }
    return '${nutrition.calories} kcal • ${nutrition.protein.toStringAsFixed(1)}g Protein • ${nutrition.fat.toStringAsFixed(1)}g Fat';
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String title, String content, {Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              // ignore: use_null_aware_elements
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  final Recipe recipe;
  const _FavoriteButton({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorited = ref.watch(isRecipeFavoritedProvider(recipe.id));
    final isLoading =
        ref.watch(toggleFavoriteProvider).isLoading;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () => ref.read(toggleFavoriteProvider.notifier).toggle(recipe.id),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.rosePink,
                ),
              )
            : Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: AppColors.rosePink,
                size: 28,
              ),
      ),
    );
  }
}
