import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/widgets/add_ingredient_modal.dart';
import 'package:nutricook/features/recipe/widgets/add_step_entry.dart';
import 'package:nutricook/features/recipe/recipe_util/recipe_nutrition_total.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';

class EditRecipeModal extends StatefulWidget {
  final String recipeId;
  final String initialName;
  final String initialDescription;
  final int initialPrepTime;
  final int initialCookTime;
  final int initialServings;
  final bool initialIsPublic;

  const EditRecipeModal({
    super.key,
    required this.recipeId,
    required this.initialName,
    required this.initialDescription,
    required this.initialPrepTime,
    required this.initialCookTime,
    required this.initialServings,
    required this.initialIsPublic,
  });

  @override
  State<EditRecipeModal> createState() => _EditRecipeModalState();
}

class _EditRecipeModalState extends State<EditRecipeModal>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;

  int _currentPage = 0;
  bool _isPublic = false;
  late List<RecipeIngredient> _ingredients;
  late List<RecipeStep> _steps;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _prepTimeController =
        TextEditingController(text: widget.initialPrepTime.toString());
    _cookTimeController =
        TextEditingController(text: widget.initialCookTime.toString());
    _servingsController =
        TextEditingController(text: widget.initialServings.toString());
    _isPublic = widget.initialIsPublic;
    _ingredients = [];
    _steps = [];
    _loadRecipeData();
  }

  Future<void> _loadRecipeData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreConstants.recipes)
          .doc(widget.recipeId)
          .get();

      if (!mounted) return;
      if (doc.exists) {
        final recipe = Recipe.fromJson({...doc.data()!, 'id': doc.id});
        setState(() {
          _ingredients = List.from(recipe.ingredients);
          _steps = List.from(recipe.steps);
        });
      }
    } catch (e) {
      debugPrint('Error loading recipe: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
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

  Future<void> _handleSave() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final prepTime = int.tryParse(_prepTimeController.text.trim()) ?? 0;
    final cookTime = int.tryParse(_cookTimeController.text.trim()) ?? 0;
    final servings = int.tryParse(_servingsController.text.trim()) ?? 1;

    if (name.isEmpty || description.isEmpty) {
      _showMessage('Please complete recipe name and description.');
      return;
    }
    if (_ingredients.isEmpty) {
      _showMessage('Please add at least one ingredient.');
      return;
    }
    if (_steps.isEmpty) {
      _showMessage('Please add at least one instruction step.');
      return;
    }
    if (servings <= 0 || prepTime < 0 || cookTime < 0) {
      _showMessage('Please provide valid recipe fields.');
      return;
    }

    try {
      setState(() => _isSaving = true);
      debugPrint('Starting recipe update for ${widget.recipeId}');
      debugPrint('Ingredients: ${_ingredients.length}, Steps: ${_steps.length}');
      
      final enrichedIngredients = await _enrichIngredientsWithNutrition(_ingredients);
      
      // Temporary Recipe Object for Nutrition Calculation
      final tempRecipe = Recipe(
        id: widget.recipeId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: enrichedIngredients,
        steps: _steps,
        servings: int.tryParse(_servingsController.text.trim()) ?? 1,
        prepTime: int.tryParse(_prepTimeController.text.trim()) ?? 0,
        cookTime: int.tryParse(_cookTimeController.text.trim()) ?? 0,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Recalculate Nutrition based on Ingredients
      final nutritionTotal = calculateRecipeNutritionTotals(tempRecipe);
      final nutritionPerServing = calculateRecipeNutritionPerServing(tempRecipe);
      
      debugPrint('Recalculated nutrition - Total calories: ${nutritionTotal.calories}, Per serving: ${nutritionPerServing.calories}');
      
      final ingredientsList = enrichedIngredients.map((i) {
        return _deepConvertToJson(i.toJson());
      }).toList();

      final stepsList = _steps.map((s) {
        return _deepConvertToJson(s.toJson());
      }).toList();
      
      final updateData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'ingredients': ingredientsList,
        'steps': stepsList,
        'prepTime': int.tryParse(_prepTimeController.text.trim()) ?? 0,
        'cookTime': int.tryParse(_cookTimeController.text.trim()) ?? 0,
        'servings': int.tryParse(_servingsController.text.trim()) ?? 1,
        'isPublic': _isPublic,
        'nutritionTotal': _deepConvertToJson(nutritionTotal.toJson()),
        'nutritionPerServing': _deepConvertToJson(nutritionPerServing.toJson()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      debugPrint('Updating recipe with nutrition data');
      
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.recipes)
          .doc(widget.recipeId)
          .update(updateData);

      debugPrint('Recipe updated successfully with nutrition values');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe updated successfully.')),
      );
      Navigator.pop(context);
    } catch (error, stackTrace) {
      debugPrint('Error updating recipe: $error');
      debugPrint('Stack trace: $stackTrace');
      if (!mounted) return;
      _showMessage('Failed to update recipe: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<List<RecipeIngredient>> _enrichIngredientsWithNutrition(
    List<RecipeIngredient> ingredients,
  ) async {
    try {
      final ingredientDocs = await FirebaseFirestore.instance
          .collection(FirestoreConstants.ingredients)
          .get();
      
      final ingredientsMap = <String, Ingredient>{};
      for (final doc in ingredientDocs.docs) {
        final ingredient = Ingredient.fromJson({...doc.data(), 'id': doc.id});
        ingredientsMap[ingredient.id] = ingredient;
      }
      
      final unitDocs = await FirebaseFirestore.instance
          .collection(FirestoreConstants.units)
          .get();
      
      final unitsMap = <String, Unit>{};
      for (final doc in unitDocs.docs) {
        final unit = Unit.fromJson({...doc.data(), 'id': doc.id});
        unitsMap[unit.id] = unit;
      }
      
      return ingredients.map((recipeIng) {
        final ingredient = ingredientsMap[recipeIng.ingredientID];
        final unit = unitsMap[recipeIng.unitID];
        
        if (ingredient == null || unit == null) {
          debugPrint('Warning: Missing ingredient or unit for ${recipeIng.name}');
          return recipeIng;
        }
        
        double calculatedWeight = 0;
        try {
          calculatedWeight = NutritionCalculator.convertToGrams(
            quantity: recipeIng.quantity,
            unit: unit,
            ingredient: ingredient,
          );
        } catch (e) {
          debugPrint('Error calculating weight for ${recipeIng.name}: $e');
          calculatedWeight = recipeIng.quantity;
        }
        

        return recipeIng.copyWith(
          name: ingredient.name,
          unitName: unit.name,
          nutritionPer100g: ingredient.nutritionPer100g,
          densityGPerMl: ingredient.densityGPerMl,
          avgWeightG: ingredient.avgWeightG,
          calculatedWeightG: calculatedWeight,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error enriching ingredients: $e');
      return ingredients;
    }
  }

  // Recursively convert complex objects to JSON Compatible Maps
  // freezed objects and nested object (For Firestore compatibility)
  dynamic _deepConvertToJson(dynamic value) {
    if (value == null) return null;
    
    if (value is Map) {
      return value.map((k, v) => MapEntry(k, _deepConvertToJson(v)));
    }
    
    if (value is List) {
      return value.map((item) => _deepConvertToJson(item)).toList();
    }
    
    if (value is! String && 
        value is! int && 
        value is! double && 
        value is! bool) {
      if (value.runtimeType.toString().contains('_')) {
        try {
          final jsonValue = (value as dynamic).toJson();
          return _deepConvertToJson(jsonValue);
        } catch (e) {
          debugPrint('Error converting $value to JSON: $e');
          return value.toString();
        }
      }
    }
    
    return value;
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return secs > 0 ? '${minutes}m ${secs}s' : '${minutes}m';
    }
    return '${secs}s';
  }

  void _showAddIngredientModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIngredientModal(
        onIngredientAdded: (item) {
          setState(() => _ingredients.add(item));
        },
      ),
    );
  }

  void _showEditIngredientModal(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIngredientModal(
        initialIngredient: _ingredients[index],
        onIngredientAdded: (item) {
          setState(() => _ingredients[index] = item);
        },
        onIngredientDeleted: () {
          setState(() => _ingredients.removeAt(index));
        },
      ),
    );
  }

  void _showAddStepModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStepModal(
        stepNumber: _steps.length + 1,
        onStepAdded: (step) {
          setState(() => _steps.add(step));
        },
      ),
    );
  }

  void _showEditStepModal(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStepModal(
        initialStep: _steps[index],
        stepNumber: index + 1,
        onStepAdded: (step) {
          setState(() => _steps[index] = step);
        },
        onStepDeleted: () {
          setState(() => _steps.removeAt(index));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editing Recipe',
                        style: const TextStyle(
                          color: AppColors.rosePink,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : 'Untitled Recipe',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Step ${_currentPage + 1} of 3',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) =>
                  setState(() => _currentPage = index),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAboutPage(),
                _buildIngredientsPage(),
                _buildStepsPage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToPreviousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.rosePink),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: AppColors.rosePink),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.rosePink),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.rosePink),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving
                        ? null
                        : (_currentPage == 2 ? _handleSave : _goToNextPage),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.rosePink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _isSaving
                          ? 'Saving...'
                          : (_currentPage == 2 ? 'Save Changes' : 'Next'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField('Recipe Name', _nameController),
          const SizedBox(height: 16),
          _buildFormField('Description', _descriptionController,
              minLines: 4, maxLines: 6),
          const SizedBox(height: 24),
          const Text('Timing & Servings',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.rosePink)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormField('Prep Time', _prepTimeController,
                    hint: 'min', keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField('Cook Time', _cookTimeController,
                    hint: 'min', keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField('Servings', _servingsController,
                    hint: 'qty', keyboardType: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.rosePink.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: SwitchListTile.adaptive(
              title: const Text('Public Recipe'),
              subtitle: const Text('Visible to all users'),
              value: _isPublic,
              activeThumbColor: AppColors.rosePink,
              onChanged: (value) => setState(() => _isPublic = value),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsPage() {
    return Column(
      children: [
        Expanded(
          child: _ingredients.isEmpty
              ? const Center(
                  child: Text('No ingredients added yet',
                      style: TextStyle(color: Colors.black38)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final item = _ingredients[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _showEditIngredientModal(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.rosePink.withValues(
                                    alpha: 0.1),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppColors.rosePink.withValues(alpha: 0.1),
                                child: Text('${index + 1}',
                                    style: const TextStyle(
                                        color: AppColors.rosePink,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        '${item.quantity} ${item.unitName}',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit_outlined,
                                  color: AppColors.rosePink, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddIngredientModal,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsPage() {
    return Column(
      children: [
        Expanded(
          child: _steps.isEmpty
              ? const Center(
                  child: Text('No steps added yet',
                      style: TextStyle(color: Colors.black38)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _showEditStepModal(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.rosePink.withValues(
                                    alpha: 0.1),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppColors.rosePink.withValues(alpha: 0.1),
                                child: Text('${index + 1}',
                                    style: const TextStyle(
                                        color: AppColors.rosePink,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(step.instruction,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    if (step.timerSeconds > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '⏱ ${_formatTimer(step.timerSeconds)}',
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit_outlined,
                                  color: AppColors.rosePink, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddStepModal,
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    String hint = '',
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.rosePink.withValues(alpha: 0.1),
                  width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.rosePink.withValues(alpha: 0.1),
                  width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.rosePink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
