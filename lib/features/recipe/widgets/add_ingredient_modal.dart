import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/library/units/unit_provider.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
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

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late TextEditingController _carbsController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;

  final List<String> categories = [
    'Proteins', 'Vegetables', 'Fruits', 'Dairy', 'Grains', 'Spices',
    'Herbs', 'Sauces', 'Seafood', 'Nuts and Seeds', 'Fats and Oils', 'Beverages',
  ];

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

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _caloriesController = TextEditingController();
    _carbsController = TextEditingController();
    _proteinController = TextEditingController();
    _fatController = TextEditingController();
    _fiberController = TextEditingController();
    _sugarController = TextEditingController();
    _sodiumController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_stage == 3) {
      setState(() => _stage = 0);
      return;
    }
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
              (ingredient.category?.toLowerCase() ?? '')
                  == _selectedCategory!.toLowerCase();
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

  void _updateNutritionFromControllers() {
    ref.read(createIngredientProvider.notifier).setNutritionValue(
      calories: int.tryParse(_caloriesController.text) ?? 0,
      carbohydrates: double.tryParse(_carbsController.text) ?? 0.0,
      protein: double.tryParse(_proteinController.text) ?? 0.0,
      fat: double.tryParse(_fatController.text) ?? 0.0,
      fiber: double.tryParse(_fiberController.text) ?? 0.0,
      sugar: double.tryParse(_sugarController.text) ?? 0.0,
      sodium: double.tryParse(_sodiumController.text) ?? 0.0,
    );
  }

  Widget _buildCreateCustomIngredientStep() {
    final state = ref.watch(createIngredientProvider);

    return SingleChildScrollView(
      key: const ValueKey(3),
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Ingredient Name'),
          const SizedBox(height: 12),
          _buildThemedTextField(
            controller: _nameController,
            hint: 'e.g., Atlantic Salmon, Avocado',
            onChanged: (val) => ref.read(createIngredientProvider.notifier).setName(val),
          ),
          const SizedBox(height: 20),
          
          _buildSectionHeader('Description'),
          const SizedBox(height: 12),
          _buildThemedTextField(
            controller: _descriptionController,
            hint: 'e.g., Fresh Atlantic salmon, rich in omega-3',
            maxLines: 3,
            onChanged: (val) => ref.read(createIngredientProvider.notifier).setDescription(val),
          ),
          const SizedBox(height: 20),
          
          _buildSectionHeader('Image'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: ImageUploadField(
              key: _ingredientImageUploadKey,
              folder: 'ingredients',
              height: 160,
              showLabel: false,
              autoUpload: false,
            ),
          ),
          const SizedBox(height: 24),
                              
          _buildSectionHeader('Categorization'),
          const SizedBox(height: 12),
          _buildThemedDropdown(state),
          const SizedBox(height: 24),

          _buildSectionHeader('Nutrition (per 100g)'),
          const SizedBox(height: 12),
          _buildNutritionToggle(state),
          const SizedBox(height: 20),

          if (state.nutritionMethod == 'manual')
            _buildManualNutritionGrid()
          else
            _buildAIStatusCard(state),

          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _stage = 0),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    side: const BorderSide(color: AppColors.rosePink, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back', style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rosePink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: state.isLoadingNutrition
                        ? null
                        : () => _submitCustomIngredient(),
                    child: state.isLoadingNutrition
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Create & Add',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87));
  }

  Widget _buildThemedTextField({required TextEditingController controller, required String hint, Function(String)? onChanged, int? maxLines}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines ?? 1,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardRose.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildThemedDropdown(dynamic state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.category,
          isExpanded: true,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
          items: categories.map((c) {
            final displayText = c
                .split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' ')
                .replaceAll('And', '&');
            return DropdownMenuItem(value: c, child: Text(displayText));
          }).toList(),
          onChanged: (val) {
            if (val != null) ref.read(createIngredientProvider.notifier).setCategory(val);
          },
        ),
      ),
    );
  }

  Widget _buildNutritionToggle(dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Input Method', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'manual', label: Text('Manual')),
              ButtonSegment(value: 'ai', label: Text('AI SmartFill')),
            ],
            selected: {state.nutritionMethod},
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              selectedBackgroundColor: AppColors.rosePink,
              selectedForegroundColor: Colors.white,
              side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSelectionChanged: (set) => ref.read(createIngredientProvider.notifier).setNutritionMethod(set.first),
          ),
        ),
      ],
    );
  }

  Widget _buildManualNutritionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildSmallNutritionField('Calories', _caloriesController, 'kcal'),
        _buildSmallNutritionField('Protein', _proteinController, 'g'),
        _buildSmallNutritionField('Carbs', _carbsController, 'g'),
        _buildSmallNutritionField('Fat', _fatController, 'g'),
        _buildSmallNutritionField('Fiber', _fiberController, 'g'),
        _buildSmallNutritionField('Sugar', _sugarController, 'g'),
        _buildSmallNutritionField('Sodium', _sodiumController, 'g'),
      ],
    );
  }

  Widget _buildSmallNutritionField(String label, TextEditingController controller, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ($unit)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45)),
        const SizedBox(height: 4),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              filled: true,
              fillColor: AppColors.cardRose.withValues(alpha: 0.1),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black12, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.rosePink, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIStatusCard(dynamic state) {
    final hasGeneratedValues = state.calories > 0 || 
        state.carbohydrates > 0 || 
        state.protein > 0 || 
        state.fat > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        children: [
          if (state.isLoadingNutrition) ...[
            const CircularProgressIndicator(color: AppColors.rosePink),
            const SizedBox(height: 12),
            const Text('Generating nutrition data...', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.rosePink)),
          ] else if (hasGeneratedValues) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(height: 12),
            const Text('AI Generated Values', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _buildGeneratedValueDisplay(state),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _updateNutritionFromControllers();
                ref.read(createIngredientProvider.notifier).generateNutritionFromAI(_nameController.text);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.rosePink),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Regenerate', style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
            const Icon(Icons.auto_awesome, color: AppColors.rosePink, size: 32),
            const SizedBox(height: 12),
            const Text('AI Prediction Ready', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _updateNutritionFromControllers();
                ref.read(createIngredientProvider.notifier).generateNutritionFromAI(_nameController.text);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.rosePink),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Generate with AI', style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildGeneratedValueDisplay(dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValueRow('Calories', '${state.calories} kcal'),
        _buildValueRow('Protein', '${state.protein.toStringAsFixed(1)} g'),
        _buildValueRow('Carbs', '${state.carbohydrates.toStringAsFixed(1)} g'),
        _buildValueRow('Fat', '${state.fat.toStringAsFixed(1)} g'),
        _buildValueRow('Fiber', '${state.fiber.toStringAsFixed(1)} g'),
        _buildValueRow('Sugar', '${state.sugar.toStringAsFixed(1)} g'),
        _buildValueRow('Sodium', '${state.sodium.toStringAsFixed(2)} g'),
      ],
    );
  }

  Widget _buildValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
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
                onPressed: ingredientState.isLoadingNutrition
                    ? null
                    : () => _submitCustomIngredient(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosePink,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: ingredientState.isLoadingNutrition
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
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

  Future<void> _submitCustomIngredient() async {
    final state = ref.read(createIngredientProvider);

    if (_nameController.text.trim().isEmpty) {
      _showSnack('Please enter an ingredient name.');
      return;
    }

    if (state.nutritionMethod == 'manual') {
      _updateNutritionFromControllers();
    }

    final navigator = Navigator.of(context);

    try {
      String? imageUrl;
      // We start the upload but don't wait for it to block the main creation
      // Firestore will sync the item first, and we can update the image URL later if needed.
      // However, for immediate offline support, we'll try to get the local path if possible,
      // but the requirement was "be able to create even without image".
      
      final uploadFuture = _ingredientImageUploadKey.currentState != null 
          ? (_ingredientImageUploadKey.currentState as dynamic)?.uploadImage()
          : Future.value(null);

      final recipeCreationState = ref.read(recipeCreationProvider);
      final recipeId = recipeCreationState.creationId;
          
      ref.read(createIngredientProvider.notifier).setTemporaryStatus(
        isTemporary: true,
        recipeId: recipeId,
      );

      // We call createIngredient but don't await the result to block the UI.
      // We need the created object to add to the recipe list though.
      // To keep it simple and responsive, we generate the ID locally or use the one in state.
      
      final currentIng = state.toIngredient(
        id: 'ing_${DateTime.now().millisecondsSinceEpoch}',
        ownerId: ref.read(currentUserIdProvider),
      );

      ref.read(createIngredientProvider.notifier).createIngredient();
      
      // Update with image URL whenever it's ready (non-blocking)
      uploadFuture.then((url) {
        if (url != null && url is String) {
          ref.read(ingredientServiceProvider).updateIngredient(currentIng.copyWith(imageURL: url));
        }
      });

      ref.read(recipeCreationProvider.notifier).addTempIngredient(currentIng);

      if (widget.onIngredientAdded != null) {
        widget.onIngredientAdded!(
          RecipeIngredient(
            ingredientID: currentIng.id,
            name: currentIng.name,
            quantity: 100,
            unitID: 'g',
            unitName: 'g',
            preparation: null,
          ),
        );
      }

      _showSnack('Ingredient "${currentIng.name}" created and added.');
      ref.read(createIngredientProvider.notifier).reset();
      
      _nameController.clear();
      _descriptionController.clear();
      _caloriesController.clear();
      _carbsController.clear();
      _proteinController.clear();
      _fatController.clear();
      _fiberController.clear();
      _sugarController.clear();
      _sodiumController.clear();

      navigator.pop();
    } catch (e) {
      _showSnack('Failed to create ingredient: $e');
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
            final selectedIngredient = _selectedIngredientId != null
                ? ingredients.firstWhere(
                    (ing) => ing.id == _selectedIngredientId,
                    orElse: () => ingredients.first,
                  )
                : null;


            // Filter out Kilocalorie unit (by id or name)
            final compatibleUnits = _filterCompatibleUnits(units, selectedIngredient)
              .where((unit) => unit.id.toLowerCase() != 'kcal' && unit.name.toLowerCase() != 'kilocalorie')
              .toList();

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

  List<Unit> _filterCompatibleUnits(List<Unit> units, Ingredient? ingredient) {
    if (ingredient == null) return units;

    return units.where((unit) {
      switch (unit.type) {
        case 'weight':
          return true;
        case 'volume':
          return ingredient.densityGPerMl != null &&
              ingredient.densityGPerMl! > 0;
        case 'count':
          return ingredient.avgWeightG != null && ingredient.avgWeightG! > 0;
        default:
          return true;
      }
    }).toList();
  }

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
          'All unit types available for this ingredient',
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
        '${missingFor.join(', ')} not available.\nOnly grams/kg and compatible units shown.',
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
