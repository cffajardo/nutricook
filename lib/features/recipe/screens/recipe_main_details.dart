import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/features/recipe/screens/recipe_about_detail.dart';
import 'package:nutricook/features/recipe/screens/recipe_ingredient_detail.dart';
import 'package:nutricook/features/recipe/screens/recipe_instruction_detail.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _pageTitles = ['About', 'Ingredients', 'Instructions'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
      ),
      title: Text(
        _pageTitles[_currentPage],
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
      ),
      centerTitle: true,
    ),
    // Use a Stack in the body for manual positioning
    body: Stack(
      children: [
        // 1. The Main Content
        Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  RecipeViewAbout(recipe: widget.recipe),
                  RecipeViewIngredients(ingredients: widget.recipe.ingredients),
                  RecipeViewInstructions(steps: widget.recipe.steps),
                ],
              ),
            ),
            // Your custom navigation bar at the bottom
            _buildBottomIndicator(),
          ],
        ),

        Positioned(
          bottom: 115, 
          right: 20,  
          child: FloatingActionButton(
            onPressed: () {
              // Start Cooking Logic
            },
            backgroundColor: AppColors.rosePink,
            elevation: 6,
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildBottomIndicator() {
    return Container(
      padding: EdgeInsets.only(
        top: 15, 
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final isSelected = _currentPage == index;
          
          return InkWell(
            onTap: () => _onTabTapped(index),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.rosePink.withValues(alpha: 0.08) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.rosePink : Colors.black12,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForIndex(index),
                    color: isSelected ? AppColors.rosePink : Colors.black26,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _pageTitles[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    color: isSelected ? AppColors.rosePink : Colors.black26,
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: return Icons.info_outline_rounded;
      case 1: return Icons.restaurant_menu_rounded;
      case 2: return Icons.format_list_numbered_rounded;
      default: return Icons.help_outline;
    }
  }
}