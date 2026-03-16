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
import 'package:nutricook/features/admin/providers/create_ingredient_provider.dart';

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

    try {
      setState(() => _isFinishing = true);

      // Step 1: Create pending custom ingredients and get their IDs
      final ingredientIdMap = <String, String>{}; // name -> realId mapping
      if (creation.pendingIngredients.isNotEmpty) {
        for (final pendingIngData in creation.pendingIngredients) {
          try {
            if (pendingIngData is Map<String, dynamic>) {
              final name = pendingIngData['name'] as String? ?? '';
              final category = pendingIngData['category'] as String? ?? 'proteins';
              final description = pendingIngData['description'] as String? ?? name;
              final calories = (pendingIngData['calories'] as num?)?.toInt() ?? 0;
              final carbs = (pendingIngData['carbohydrates'] as num?)?.toDouble() ?? 0.0;
              final protein = (pendingIngData['protein'] as num?)?.toDouble() ?? 0.0;
              final fat = (pendingIngData['fat'] as num?)?.toDouble() ?? 0.0;
              final fiber = (pendingIngData['fiber'] as num?)?.toDouble() ?? 0.0;
              final sugar = (pendingIngData['sugar'] as num?)?.toDouble() ?? 0.0;
              final sodium = (pendingIngData['sodium'] as num?)?.toDouble() ?? 0.0;

              // Set provider state from the pending ingredient data
              ref.read(createIngredientProvider.notifier).setName(name);
              ref.read(createIngredientProvider.notifier).setCategory(category);
              ref.read(createIngredientProvider.notifier).setDescription(description);
              ref.read(createIngredientProvider.notifier).setNutritionValue(
                calories: calories,
                carbohydrates: carbs,
                protein: protein,
                fat: fat,
                fiber: fiber,
                sugar: sugar,
                sodium: sodium,
              );

              // Generate physical property (avgWeight for solids)
              await ref.read(createIngredientProvider.notifier).generatePhysicalProperty(name);

              final createdIng = await ref
                  .read(createIngredientProvider.notifier)
                  .createIngredient();

              if (createdIng != null) {
                // Map ingredient name to real ingredient ID
                ingredientIdMap[name] = createdIng.id;
              }
            }
          } catch (e) {
            _showMessage('Failed to create custom ingredient: $e');
            return;
          }
        }
      }

      // Step 2: Update recipe ingredients with real IDs
      var finalIngredients = creation.ingredients;
      if (ingredientIdMap.isNotEmpty) {
        finalIngredients = creation.ingredients.map((ing) {
          final realId = ingredientIdMap[ing.name];
          if (realId != null && ing.ingredientID.startsWith('temp_')) {
            return ing.copyWith(ingredientID: realId);
          }
          return ing;
        }).toList();
      }

      final baseRecipe = Recipe(
        id: creation.isEditing ? creation.editingRecipeId : '',
        name: creation.name.trim(),
        description: creation.description.trim(),
        ingredients: finalIngredients,
        steps: creation.steps,
        isPublic: creation.isPublic,
        servings: creation.servings,
        cookTime: creation.cookTimeMinutes,
        prepTime: creation.prepTimeMinutes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: creation.tags,
      );

      // Step 3: Save the recipe
      if (creation.isEditing) {
        await ref
            .read(recipeServiceProvider)
            .updateRecipe(
              recipe: baseRecipe,
              ingredientsMap: ingredientsMap,
              unitsMap: unitsMap,
            );
      } else {
        await ref
            .read(recipeServiceProvider)
            .createRecipe(
              recipe: baseRecipe,
              ingredientsMap: ingredientsMap,
              unitsMap: unitsMap,
            );
      }

      ref.read(recipeCreationProvider.notifier).clear();
      if (!mounted) return;
      final rootMessenger = ScaffoldMessenger.of(
        Navigator.of(context, rootNavigator: true).context,
      );
      Navigator.pop(context);
      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              creation.isEditing 
                ? 'Recipe updated successfully.' 
                : 'Recipe created successfully.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      _showMessage(
        creation.isEditing 
          ? 'Failed to update recipe: $error'
          : 'Failed to create recipe: $error',
      );
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
        title: Builder(
          builder: (context) {
            final creation = ref.watch(recipeCreationProvider);
            return Text(
              '${creation.isEditing ? 'Edit' : 'Create'} Recipe - Step ${_currentPage + 1} of 3',
              style: const TextStyle(
                color: AppColors.rosePink,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            );
          },
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
