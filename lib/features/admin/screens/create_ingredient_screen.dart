import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/admin/providers/create_ingredient_provider.dart';
import 'package:nutricook/widgets/image_upload_field.dart';

class CreateIngredientScreen extends ConsumerStatefulWidget {
  const CreateIngredientScreen({super.key});

  @override
  ConsumerState<CreateIngredientScreen> createState() =>
      _CreateIngredientScreenState();
}

class _CreateIngredientScreenState
    extends ConsumerState<CreateIngredientScreen> {
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _carbsController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;

  final List<String> categories = [
    'proteins',
    'vegetables',
    'fruits',
    'dairy',
    'grains',
    'spices',
    'herbs',
    'sauces',
    'seafood',
    'nuts-and-seeds',
    'fats-and-oils',
    'beverages',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
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
    _nameController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  void _updateNutritionFromControllers() {
    final state = ref.read(createIngredientProvider);
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Ingredient created successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createIngredientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ingredient'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            _buildSectionHeader('Ingredient Name'),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              onChanged: (value) {
                ref.read(createIngredientProvider.notifier).setName(value);
              },
              decoration: InputDecoration(
                hintText: 'e.g., Tomato, Chicken Breast, Olive Oil',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Ingredient Image Upload
            _buildSectionHeader('Ingredient Image'),
            const SizedBox(height: 12),
            ImageUploadField(
              folder: 'ingredients',
              label: 'Upload Image',
              height: 180,
              onSuccess: (imageUrl) {
                ref
                    .read(createIngredientProvider.notifier)
                    .setImageUrl(imageUrl);
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image upload failed: $error'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Category selection
            _buildSectionHeader('Category'),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: state.category,
              isExpanded: true,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_formatCategory(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(createIngredientProvider.notifier)
                      .setCategory(value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Ingredient type
            _buildSectionHeader('Ingredient Type'),
            const SizedBox(height: 12),
            _buildSegmentedButton(),
            const SizedBox(height: 24),

            // Physical property auto-generation
            _buildPhysicalPropertySection(),
            const SizedBox(height: 24),

            // Nutrition input method
            _buildSectionHeader('Nutrition Information'),
            const SizedBox(height: 12),
            _buildNutritionMethodToggle(),
            const SizedBox(height: 16),

            // Nutrition fields
            if (state.nutritionMethod == 'manual')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNutritionField(
                    label: 'Calories (per 100g)',
                    controller: _caloriesController,
                    hintText: '0',
                    isInteger: true,
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionField(
                    label: 'Protein (g)',
                    controller: _proteinController,
                    hintText: '0.0',
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionField(
                    label: 'Carbohydrates (g)',
                    controller: _carbsController,
                    hintText: '0.0',
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionField(
                    label: 'Fat (g)',
                    controller: _fatController,
                    hintText: '0.0',
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionField(
                    label: 'Fiber (g)',
                    controller: _fiberController,
                    hintText: '0.0',
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionField(
                    label: 'Sugar (g)',
                    controller: _sugarController,
                    hintText: '0.0',
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionField(
                    label: 'Sodium (mg)',
                    controller: _sodiumController,
                    hintText: '0.0',
                  ),
                ],
              )
            else
              Column(
                children: [
                  if (state.isLoadingNutrition)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.rosePink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.rosePink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Generating nutrition data...'),
                        ],
                      ),
                    )
                  else if (state.calories > 0 ||
                      state.protein > 0 ||
                      state.carbohydrates > 0 ||
                      state.fat > 0 ||
                      state.fiber > 0 ||
                      state.sugar > 0 ||
                      state.sodium > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Generated Nutrition Values (per 100g)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Calories: ${state.calories} kcal'),
                              Text(
                                'Protein: ${state.protein.toStringAsFixed(1)}g',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Carbs: ${state.carbohydrates.toStringAsFixed(1)}g',
                              ),
                              Text(
                                'Fat: ${state.fat.toStringAsFixed(1)}g',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rosePink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: state.isLoadingNutrition
                          ? null
                          : () {
                              _updateNutritionFromControllers();
                              ref
                                  .read(createIngredientProvider.notifier)
                                  .generateNutritionFromAI(
                                    _nameController.text,
                                  );
                            },
                      child: const Text(
                        'Generate Nutrition',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Error message
            if (state.error.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  state.error,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 24),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosePink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  _updateNutritionFromControllers();
                  final result = await ref
                      .read(createIngredientProvider.notifier)
                      .createIngredient();

                  if (result != null && mounted) {
                    _showSuccessDialog();
                  }
                },
                child: const Text(
                  'Create Ingredient',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSegmentedButton() {
    final state = ref.watch(createIngredientProvider);

    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(label: Text('Solid'), value: false),
        ButtonSegment(label: Text('Liquid'), value: true),
      ],
      selected: {state.isLiquid},
      onSelectionChanged: (selected) {
        ref
            .read(createIngredientProvider.notifier)
            .setIngredientType(selected.first);
      },
    );
  }

  Widget _buildPhysicalPropertySection() {
    final state = ref.watch(createIngredientProvider);

    if (_nameController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final label = state.isLiquid
        ? 'Density: ${state.density?.toStringAsFixed(2)} g/ml'
        : 'Avg. Weight: ${state.avgWeight?.toStringAsFixed(1)}g';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          state.isLiquid ? 'Liquid Density' : 'Average Piece Weight',
        ),
        const SizedBox(height: 12),
        if (state.isLoadingPhysicalProperty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.rosePink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.rosePink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Generating ${state.isLiquid ? 'density' : 'weight'} data...',
                ),
              ],
            ),
          )
        else if (state.isLiquid && state.density != null ||
            !state.isLiquid && state.avgWeight != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label),
                Icon(
                  Icons.check_circle,
                  color: Colors.green[700],
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: state.isLoadingPhysicalProperty
                ? null
                : () {
                    ref
                        .read(createIngredientProvider.notifier)
                        .generatePhysicalProperty(
                          _nameController.text,
                        );
                  },
            child: Text(
              'Generate ${state.isLiquid ? 'Density' : 'Average Weight'}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionMethodToggle() {
    final state = ref.watch(createIngredientProvider);

    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(label: Text('Manual Input'), value: 'manual'),
        ButtonSegment(label: Text('Generate with AI'), value: 'ai'),
      ],
      selected: {state.nutritionMethod},
      onSelectionChanged: (selected) {
        ref
            .read(createIngredientProvider.notifier)
            .setNutritionMethod(selected.first);
      },
    );
  }

  Widget _buildNutritionField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isInteger = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isInteger
              ? TextInputType.number
              : const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  String _formatCategory(String category) {
    return category
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
