import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class RecipeSubCategoryScreen extends ConsumerWidget {
  final String category; // Passed from GoRouter
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
                  category, // Dynamically shows "Cuisine", "Nutrition", etc.
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
    final List<Map<String, String>> items = _getMockDataForCategory(category);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(context, items[index]['name']!, items[index]['icon']!);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, String name, String icon) {
    return GestureDetector(
      onTap: () {
      context.pushNamed(
        'recipeList', 
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

  List<Map<String, String>> _getMockDataForCategory(String cat) {
    if (cat == 'Cuisine') return [{'name': 'Italian', 'icon': '🍝'}, {'name': 'Mexican', 'icon': '🌮'}];
    if (cat == 'Nutrition') return [{'name': 'Low Cal', 'icon': '🥗'}, {'name': 'High Pro', 'icon': '🍗'}];
    // Add logic for Dietary and Difficulty
    return [];
  }
}