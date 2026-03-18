import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/library/units/unit_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_select_ingredients.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_about_page.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_instructions.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';

class RecipeCreateFlow extends ConsumerStatefulWidget {
  const RecipeCreateFlow({super.key});

  @override
  ConsumerState<RecipeCreateFlow> createState() => _RecipeCreateFlowState();
}

class _RecipeCreateFlowState extends ConsumerState<RecipeCreateFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _goToPreviousPage() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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

    final baseIngredientsMap = ref.read(ingredientsMapProvider).asData?.value;
    final unitsMap = ref.read(unitsMapProvider).asData?.value;
    if (baseIngredientsMap == null || unitsMap == null) {
      _showMessage('Ingredient and unit data is still loading. Please try again.');
      return;
    }

    final ingredientsMap = <String, Ingredient>{
      ...baseIngredientsMap,
      ...creation.tempIngredients,
    };

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      setState(() => _isFinishing = true);

      final recipeId = creation.isEditing ? creation.editingRecipeId : 'recipe_${DateTime.now().millisecondsSinceEpoch}';

      final baseRecipe = Recipe(
        id: recipeId,
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

      if (creation.isEditing) {
        ref.read(recipeServiceProvider).updateRecipe(recipe: baseRecipe, ingredientsMap: ingredientsMap, unitsMap: unitsMap);
      } else {
        ref.read(recipeServiceProvider).createRecipe(recipe: baseRecipe, ingredientsMap: ingredientsMap, unitsMap: unitsMap);
      }

      ref.read(recipeCreationProvider.notifier).finalizeTempIngredients(creation.creationId);
      ref.read(recipeCreationProvider.notifier).clear();

      navigator.pop();
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(creation.isEditing ? 'Recipe updated successfully.' : 'Recipe created successfully.'), behavior: SnackBarBehavior.floating));
    } catch (error) {
      await ref.read(recipeCreationProvider.notifier).cleanupTempIngredients(creation.creationId);
      if (mounted) {
        _showMessage(creation.isEditing ? 'Failed to update recipe: $error (Ingredients rolled back)' : 'Failed to create recipe: $error (Ingredients rolled back)');
      }
    } finally {
      if (mounted) setState(() => _isFinishing = false);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK', style: TextStyle(color: AppColors.rosePink))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(recipeCreationProvider);

    return PageView(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentPage = index),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        CreateRecipeAboutPage(onNext: _goToNextPage),
        CreateRecipeIngredientsPage(onBack: _goToPreviousPage, onNext: _goToNextPage),
        CreateRecipeInstructionsPage(onBack: _goToPreviousPage, onFinish: _handleFinish, isFinishing: _isFinishing),
      ],
    );
  }
}
