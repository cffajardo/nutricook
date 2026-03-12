import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/library/units/unit_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_select_ingredients.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_about_page.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_instructions.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  Future<void> _handleFinish() async {
    if (_isFinishing) return;

    final creation = ref.read(recipeCreationProvider);
    if (!creation.canProceedFromAbout) {
      _showMessage('Please complete recipe name and description.');
      return;
    }
    if (creation.ingredients.isEmpty) {
      _showMessage('Please add at least one ingredient.');
      return;
    }
    if (creation.steps.isEmpty) {
      _showMessage('Please add at least one instruction step.');
      return;
    }

    final ingredientsMap = ref.read(ingredientsMapProvider).asData?.value;
    final unitsMap = ref.read(unitsMapProvider).asData?.value;
    if (ingredientsMap == null || unitsMap == null) {
      _showMessage(
        'Ingredient and unit data is still loading. Please try again.',
      );
      return;
    }

    final baseRecipe = Recipe(
      id: '',
      name: creation.name.trim(),
      description: creation.description.trim(),
      ingredients: creation.ingredients,
      steps: creation.steps,
      isPublic: creation.isPublic,
      servings: creation.servings,
      cookTime: creation.cookTimeMinutes,
      prepTime: creation.prepTimeMinutes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: creation.tags,
    );

    try {
      setState(() => _isFinishing = true);
      await ref
          .read(recipeServiceProvider)
          .createRecipe(
            recipe: baseRecipe,
            ingredientsMap: ingredientsMap,
            unitsMap: unitsMap,
          );

      ref.read(recipeCreationProvider.notifier).clear();
      if (!mounted) return;
      final rootMessenger = ScaffoldMessenger.of(
        Navigator.of(context, rootNavigator: true).context,
      );
      Navigator.pop(context);
      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Recipe created successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      _showMessage('Failed to create recipe: $error');
    } finally {
      if (mounted) {
        setState(() => _isFinishing = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.rosePink),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep draft creation state alive across page transitions in this flow.
    ref.watch(recipeCreationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            ref.read(recipeCreationProvider.notifier).clear();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: Colors.black87),
        ),
        title: Text(
          'Step ${_currentPage + 1} of 3',
          style: const TextStyle(
            color: AppColors.rosePink,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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

          CreateRecipeInstructionsPage(
            onBack: _goToPreviousPage,
            onFinish: _handleFinish,
            isFinishing: _isFinishing,
          ),
        ],
      ),
    );
  }
}
