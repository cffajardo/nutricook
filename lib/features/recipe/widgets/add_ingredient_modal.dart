import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/library/units/unit_provider.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/admin/providers/create_ingredient_provider.dart';
import 'package:nutricook/widgets/image_upload_field.dart';

class AddIngredientModal extends ConsumerStatefulWidget {
  final ValueChanged<RecipeIngredient>? onIngredientAdded;
  final ValueChanged<String>? onIngredientPicked;
  final VoidCallback? onIngredientDeleted;
  final RecipeIngredient? initialIngredient;

  const AddIngredientModal({
    super.key,
    this.onIngredientAdded,
    this.onIngredientPicked,
    this.onIngredientDeleted,
    this.initialIngredient,
  }) : assert(
         onIngredientAdded != null || onIngredientPicked != null,
         'Provide onIngredientAdded or onIngredientPicked.',
       );

  @override
  ConsumerState<AddIngredientModal> createState() => _AddIngredientModalState();
}

class _AddIngredientModalState extends ConsumerState<AddIngredientModal> {
  late int _stage;
  String? _selectedCategory;
  String? _selectedIngredientId;
  String? _selectedIngredientName;

  late String _selectedProcess;
  String? _selectedUnitId;
  late TextEditingController _amountController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<State<ImageUploadField>> _ingredientImageUploadKey = GlobalKey();

  final List<String> _processes = const <String>[
    'None',
    'Raw',
    'Minced',
    'Chopped',
    'Diced',
    'Sliced',
    'Crushed',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialIngredient;
    if (initial != null) {
      _stage = 2;
      _selectedIngredientId = initial.ingredientID;
      _selectedIngredientName = initial.name;
      _selectedProcess = initial.preparation ?? 'None';
      _selectedUnitId = initial.unitID;
      _amountController = TextEditingController(
        text: _formatQuantity(initial.quantity),
      );
    } else {
      _stage = 0;
      _selectedProcess = 'None';
      _amountController = TextEditingController(text: '100');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_stage > 0) {
      setState(() => _stage--);
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildModalHeader(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildStageContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader() {
    final modalTitle = widget.onIngredientPicked != null
        ? 'Select Ingredient'
        : 'Add Ingredient';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _handleBack,
            icon: Icon(
              _stage == 0 ? Icons.close : Icons.chevron_left,
              color: AppColors.rosePink,
              size: 28,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                modalTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case 0:
        return _buildCategoryGrid();
      case 1:
        return _buildIngredientSelectionStep();
      case 2:
        return _buildDetailForm();
      case 3:
        return _buildCreateCustomIngredientStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryGrid() {
    final categories = <String>[
      IngredientCategory.proteins,
      IngredientCategory.vegetables,
      IngredientCategory.fruits,
      IngredientCategory.dairy,
      IngredientCategory.grains,
      IngredientCategory.spices,
      IngredientCategory.herbs,
      IngredientCategory.sauces,
      IngredientCategory.seafood,
      IngredientCategory.nutsAndSeeds,
      IngredientCategory.fatsAndOils,
      IngredientCategory.beverages,
    ];

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            key: const ValueKey(0),
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildSelectionTile(
                label: category,
                onTap: () => setState(() {
                  _selectedCategory = category;
                  _stage = 1;
                }),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          child: OutlinedButton(
            onPressed: () => setState(() => _stage = 3),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(
                color: AppColors.rosePink,
                width: 2,
              ),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.rosePink, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Create Custom Ingredient',
                    style: TextStyle(
                      color: AppColors.rosePink,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientSelectionStep() {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final query = _searchController.text.trim().toLowerCase();

    return ingredientsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Failed to load ingredients: $error')),
      data: (ingredients) {
        final filtered = ingredients.where((ingredient) {
          final inCategory =
              _selectedCategory == null ||
              ingredient.category.toLowerCase() ==
                  _selectedCategory!.toLowerCase();
          if (!inCategory) return false;
          if (query.isEmpty) return true;
          return ingredient.name.toLowerCase().contains(query);
        }).toList();

        return Column(
          key: const ValueKey(1),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No ingredients found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ingredient = filtered[index];
                        return _buildSelectionTile(
                          label: ingredient.name,
                          onTap: () {
                            if (widget.onIngredientPicked != null) {
                              widget.onIngredientPicked!(ingredient.id);
                              Navigator.pop(context);
                              return;
                            }

                            setState(() {
                              _selectedIngredientId = ingredient.id;
                              _selectedIngredientName = ingredient.name;
                              _stage = 2;
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateCustomIngredientStep() {
    return Padding(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Custom Ingredient',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create and add a custom ingredient. It will be saved when you save your recipe.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _buildSimpleIngredientForm(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleIngredientForm() {
    final ingredientState = ref.watch(createIngredientProvider);
    final nameController = TextEditingController(text: ingredientState.name);
    final caloriesController = TextEditingController(
      text: ingredientState.calories > 0 ? ingredientState.calories.toString() : '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleTextField(
          label: 'Ingredient Name *',
          hint: 'e.g., Atlantic Salmon',
          controller: nameController,
          onChanged: (val) => ref.read(createIngredientProvider.notifier).setName(val),
        ),
        const SizedBox(height: 16),
        _buildSimpleTextField(
          label: 'Category',
          hint: 'Select a category',
          controller: TextEditingController(text: ingredientState.category),
          isReadOnly: true,
          onTap: () => _showCategoryPicker(),
        ),
        const SizedBox(height: 16),
        _buildSimpleTextField(
          label: 'Calories (per 100g) *',
          hint: '150',
          controller: caloriesController,
          keyboardType: TextInputType.number,
          onChanged: (val) {
            final cal = int.tryParse(val) ?? 0;
            ref.read(createIngredientProvider.notifier).setNutritionValue(
              calories: cal,
              carbohydrates: ingredientState.carbohydrates,
              protein: ingredientState.protein,
              fat: ingredientState.fat,
              fiber: ingredientState.fiber,
              sugar: ingredientState.sugar,
              sodium: ingredientState.sodium,
            );
          },
        ),
        const SizedBox(height: 24),
        ImageUploadField(
          key: _ingredientImageUploadKey,
          folder: 'ingredients',
          label: 'Ingredient Image (Optional)',
          height: 160,
          autoUpload: false,
          initialImageUrl: ingredientState.imageUrl.isEmpty ? null : ingredientState.imageUrl,
          onSuccess: (imageUrl) {
            ref.read(createIngredientProvider.notifier).setImageUrl(imageUrl);
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _stage = 1),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  side: const BorderSide(color: AppColors.rosePink, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _submitCustomIngredient(nameController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosePink,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create & Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isReadOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: isReadOnly,
          onTap: onTap,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.cardRose.withValues(alpha: 0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.rosePink.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.rosePink.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryPicker() {
    final categories = <String>[
      IngredientCategory.proteins,
      IngredientCategory.vegetables,
      IngredientCategory.fruits,
      IngredientCategory.dairy,
      IngredientCategory.grains,
      IngredientCategory.spices,
      IngredientCategory.herbs,
      IngredientCategory.sauces,
      IngredientCategory.seafood,
      IngredientCategory.nutsAndSeeds,
      IngredientCategory.fatsAndOils,
      IngredientCategory.beverages,
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () {
                ref.read(createIngredientProvider.notifier).setCategory(cat);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardRose.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.2)),
                ),
                child: Center(
                  child: Text(
                    cat,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitCustomIngredient(TextEditingController nameController) async {
    final ingredientState = ref.read(createIngredientProvider);

    if (nameController.text.trim().isEmpty) {
      _showSnack('Please enter an ingredient name');
      return;
    }

    if (ingredientState.calories == 0) {
      _showSnack('Please enter calories');
      return;
    }

    if (ingredientState.category.isEmpty) {
      _showSnack('Please select a category');
      return;
    }

    // Upload image if one was selected
    String imageUrl = ingredientState.imageUrl;
    if (_ingredientImageUploadKey.currentState != null) {
      try {
        final uploadedUrl = await (_ingredientImageUploadKey.currentState as dynamic)?.uploadImage();
        if (uploadedUrl != null && uploadedUrl is String) {
          imageUrl = uploadedUrl;
          ref.read(createIngredientProvider.notifier).setImageUrl(imageUrl);
        }
      } catch (e) {
        if (mounted) {
          _showSnack('Failed to upload image: $e');
        }
        return;
      }
    }

    // Convert ingredient state to map for storage in pending ingredients
    final ingredientMap = {
      'name': ingredientState.name,
      'description': ingredientState.description,
      'category': ingredientState.category,
      'isLiquid': ingredientState.isLiquid,
      'calories': ingredientState.calories,
      'carbohydrates': ingredientState.carbohydrates,
      'protein': ingredientState.protein,
      'fat': ingredientState.fat,
      'fiber': ingredientState.fiber,
      'sugar': ingredientState.sugar,
      'sodium': ingredientState.sodium,
      'imageUrl': imageUrl,
    };

    // Store in pending ingredients instead of saving immediately
    ref.read(recipeCreationProvider.notifier).addPendingIngredient(ingredientMap);

    // Add to recipe with a temporary ID
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    if (widget.onIngredientAdded != null) {
      widget.onIngredientAdded!(
        RecipeIngredient(
          ingredientID: tempId,
          name: ingredientState.name,
          quantity: 100,
          unitID: 'g',
          unitName: 'g',
          preparation: null,
        ),
      );
    }

    _showSnack('Ingredient added! Will be saved when you save the recipe.');
    ref.read(createIngredientProvider.notifier).reset();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildDetailForm() {
    final isEditing = widget.initialIngredient != null;
    final unitsAsync = ref.watch(unitsProvider);
    final ingredientsAsync = ref.watch(ingredientsProvider);

    return unitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Failed to load units: $error')),
      data: (units) {
        if (units.isEmpty) {
          return const Center(child: Text('No units found.'));
        }

        return ingredientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Failed to load ingredients: $error')),
          data: (ingredients) {
            // Find the selected ingredient to check its properties
            final selectedIngredient = _selectedIngredientId != null
                ? ingredients.firstWhere(
                    (ing) => ing.id == _selectedIngredientId,
                    orElse: () => ingredients.first,
                  )
                : null;

            // Filter units based on ingredient properties
            final compatibleUnits =
                _filterCompatibleUnits(units, selectedIngredient);

            _selectedUnitId ??= _resolveInitialUnitId(compatibleUnits);
            final selectedUnit = _findUnitById(compatibleUnits, _selectedUnitId) ??
                compatibleUnits.first;

        return Padding(
          key: const ValueKey(2),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDisplayField(
                'Ingredient',
                _selectedIngredientName ?? 'Select ingredient',
                Icons.restaurant,
                onTap: () => setState(() => _stage = 0),
              ),
              const SizedBox(height: 16),
              if (_selectedProcess != 'None') ...[
                _buildDisplayField(
                  'Preparation Style',
                  _selectedProcess,
                  Icons.settings_suggest_outlined,
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Preparation Style',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildDropdownField(
                value: _selectedProcess,
                items: _processes,
                onChanged: (value) =>
                    setState(() => _selectedProcess = value ?? 'None'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Measurement',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildSmallTextField(
                      controller: _amountController,
                      hint: 'Qty',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildUnitDropdown(
                      units: compatibleUnits,
                      selectedUnitId: selectedUnit.id,
                      ingredient: selectedIngredient,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildUnitCompatibilityInfo(selectedIngredient),
              const Spacer(),
              Row(
                children: [
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        onPressed: widget.onIngredientDeleted == null
                            ? null
                            : () {
                                widget.onIngredientDeleted!();
                                Navigator.pop(context);
                              },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitIngredient(selectedUnit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rosePink,
                        minimumSize: const Size(0, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update Ingredient' : 'Add to Recipe',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }

  void _submitIngredient(Unit selectedUnit) {
    final ingredientId = _selectedIngredientId;
    final ingredientName = _selectedIngredientName;
    final quantity = double.tryParse(_amountController.text.trim());

    if (ingredientId == null ||
        ingredientName == null ||
        ingredientName.isEmpty) {
      _showSnack('Please select an ingredient.');
      return;
    }
    if (quantity == null || quantity <= 0) {
      _showSnack('Please enter a valid quantity.');
      return;
    }

    final onIngredientAdded = widget.onIngredientAdded;
    if (onIngredientAdded == null) {
      Navigator.pop(context);
      return;
    }

    onIngredientAdded(
      RecipeIngredient(
        ingredientID: ingredientId,
        name: ingredientName,
        quantity: quantity,
        unitID: selectedUnit.id,
        unitName: selectedUnit.name,
        preparation: _selectedProcess == 'None' ? null : _selectedProcess,
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.rosePink,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.cardRose.withValues(alpha: 0.3),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: AppColors.rosePink.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitDropdown({
    required List<Unit> units,
    required String selectedUnitId,
    Ingredient? ingredient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedUnitId,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.rosePink),
          items: units
              .map(
                (unit) => DropdownMenuItem<String>(
                  value: unit.id,
                  child: Text(unit.name),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedUnitId = value),
        ),
      ),
    );
  }

  /// Filter units based on ingredient properties
  List<Unit> _filterCompatibleUnits(List<Unit> units, Ingredient? ingredient) {
    if (ingredient == null) return units;

    return units.where((unit) {
      switch (unit.type) {
        case 'weight':
          // Weight units always work
          return true;
        case 'volume':
          // Volume units only work if ingredient has density
          return ingredient.densityGPerMl != null &&
              ingredient.densityGPerMl! > 0;
        case 'count':
          // Count units only work if ingredient has average weight
          return ingredient.avgWeightG != null && ingredient.avgWeightG! > 0;
        default:
          return true;
      }
    }).toList();
  }

  /// Build a helpful message about unit compatibility
  Widget _buildUnitCompatibilityInfo(Ingredient? ingredient) {
    if (ingredient == null) {
      return const SizedBox.shrink();
    }

    final List<String> compatibleTypes = ['weight'];
    final List<String> missingFor = [];

    if (ingredient.densityGPerMl == null || ingredient.densityGPerMl! <= 0) {
      missingFor.add('volume units (cups, ml, liters)');
    } else {
      compatibleTypes.add('volume');
    }

    if (ingredient.avgWeightG == null || ingredient.avgWeightG! <= 0) {
      missingFor.add('pieces/count units');
    } else {
      compatibleTypes.add('count');
    }

    if (missingFor.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Text(
          '✓ All unit types available for this ingredient',
          style: TextStyle(
            color: Colors.green,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '⚠ ${missingFor.join(', ')} not available.\nOnly grams/kg and compatible units shown.',
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.rosePink),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSmallTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardRose.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.rosePink.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSelectionTile({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.rosePink.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon ?? Icons.restaurant_outlined,
              color: AppColors.rosePink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayField(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardRose.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.rosePink),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.black38),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.sync_rounded, color: AppColors.rosePink, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Unit? _findUnitById(List<Unit> units, String? id) {
    if (id == null) return null;
    for (final unit in units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  String _resolveInitialUnitId(List<Unit> units) {
    final initialId = widget.initialIngredient?.unitID;
    if (initialId != null && _findUnitById(units, initialId) != null) {
      return initialId;
    }

    final gramLike = units.where(
      (unit) => unit.id.toLowerCase() == 'g' || unit.name.toLowerCase() == 'g',
    );
    if (gramLike.isNotEmpty) return gramLike.first.id;

    return units.first.id;
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    var text = value.toStringAsFixed(2);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
