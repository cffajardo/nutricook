import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_select_ingredients.dart';
import 'package:nutricook/features/recipe/widgets/recipe_create_about_page.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
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
          icon: const Icon(Icons.close, color: Colors.black87),
        ),
        title: Text(
          'Step ${_currentPage + 1} of 3', 
          style: const TextStyle(color: AppColors.rosePink, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          CreateRecipeAboutPage(onNext: _goToNextPage),
          CreateRecipeIngredientsPage(
            onBack: _goToPreviousPage,
            onNext: _goToNextPage,
          ),
          const Center(child: Text('Step 3: Instructions')),
        ],
      ),
    );
  }
}