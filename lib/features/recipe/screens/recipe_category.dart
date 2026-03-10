import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/routing/app_routes.dart';

class RecipeSubCategoryScreen extends ConsumerWidget {
  final String category; 
  const RecipeSubCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic: ref.watch(subCategoryProvider(category))

    return Container(
      color: const Color(0xFFFFF9FA),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: _buildDynamicGrid(ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(), 
            icon: const Icon(Icons.chevron_left, color: AppColors.rosePink, size: 32),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(
                  category, 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicGrid(WidgetRef ref) {
    final List<String> tags = _subCategoriesFor(category);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return _buildCategoryCard(
          context,
          _displayName(tag),
          _iconFor(tag),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, String name, String icon) {
    return GestureDetector(
      onTap: () {
      context.pushNamed(
        AppRoutes.recipeListName,
        pathParameters: {
          'category': category,     
          'subCategoryName': name,   
        },
      );
    },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          // Unified 1.5 width border
          border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.14), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _subCategoriesFor(String cat) {
    if (cat == 'Cuisine') return RecipeTags.cuisine;
    if (cat == 'Nutrition') return RecipeTags.nutrition;
    if (cat == 'Dietary') return RecipeTags.dietary;
    if (cat == 'Difficulty') return RecipeTags.difficulty;
    return <String>[];
  }

  String _displayName(String tag) {
    return tag
        .split('-')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  String _iconFor(String tag) {
    switch (tag) {
      case 'italian':
        return '🍝';
      case 'mexican':
        return '🌮';
      case 'japanese':
        return '🍣';
      case 'chinese':
        return '🥢';
      case 'american':
        return '🍔';
      case 'vegetarian':
        return '🥕';
      case 'vegan':
        return '🌱';
      case 'gluten-free':
        return '🌾';
      case 'dairy-free':
        return '🥛';
      case 'low-carb':
        return '🥬';
      case 'high-protein':
        return '💪';
      case 'low-fat':
        return '🥣';
      case 'keto':
        return '🥓';
      case 'paleo':
        return '🥩';
      case 'whole30':
        return '🍽️';
      case 'low-calorie':
        return '🍏';
      case 'high-fiber':
        return '🌾';
      case 'high-carb':
        return '🍞';
      case 'low-sugar':
        return '🫐';
      case 'easy':
        return '🙂';
      case 'medium':
        return '😎';
      case 'hard':
        return '🔥';
      default:
        return '🍽️';
    }
  }
}