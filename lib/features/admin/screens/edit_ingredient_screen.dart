import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/admin/providers/create_ingredient_provider.dart';
import 'package:nutricook/widgets/image_upload_field.dart';

class EditIngredientScreen extends ConsumerStatefulWidget {
  final String ingredientId;

  const EditIngredientScreen({super.key, required this.ingredientId});

  @override
  ConsumerState<EditIngredientScreen> createState() => _EditIngredientScreenState();
}

class _EditIngredientScreenState extends ConsumerState<EditIngredientScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late TextEditingController _carbsController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;

  final _imageUploadKey = GlobalKey();

  final List<String> categories = [
    'Proteins', 'Vegetables', 'Fruits', 'Dairy', 'Grains', 'Spices',
    'Herbs', 'Sauces', 'Seafood', 'Nuts and Seeds', 'Fats and Oils', 'Beverages',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(createIngredientProvider);
    _nameController = TextEditingController(text: state.name);
    _descriptionController = TextEditingController(text: state.description);
    _caloriesController = TextEditingController(text: state.calories.toString());
    _carbsController = TextEditingController(text: state.carbohydrates.toString());
    _proteinController = TextEditingController(text: state.protein.toString());
    _fatController = TextEditingController(text: state.fat.toString());
    _fiberController = TextEditingController(text: state.fiber.toString());
    _sugarController = TextEditingController(text: state.sugar.toString());
    _sodiumController = TextEditingController(text: state.sodium.toStringAsFixed(2));
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createIngredientProvider);

    ref.listen(createIngredientProvider, (previous, next) {
      if (next.error.isNotEmpty && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error), backgroundColor: Colors.red),
        );
      }
      if (next.success && !(previous?.success ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient updated successfully!'), backgroundColor: Colors.green),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        ),
        title: const Text(
          'Edit Ingredient',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Ingredient Name'),
            const SizedBox(height: 16),
            _buildThemedTextField(
              controller: _nameController,
              hint: 'e.g., Atlantic Salmon, Avocado',
              onChanged: (val) => ref.read(createIngredientProvider.notifier).setName(val),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('Description'),
            const SizedBox(height: 16),
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
                key: _imageUploadKey,
                folder: 'ingredients',
                height: 160,
                showLabel: false,
                autoUpload: false,
                initialImageUrl: state.imageUrl,
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

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosePink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: state.isLoadingNutrition
                    ? null
                    : () async {
                        if (state.nutritionMethod == 'manual') {
                          _updateNutritionFromControllers();
                        }

                        final imageUrl = await (_imageUploadKey.currentState as dynamic)?.uploadImage();
                        if (imageUrl != null) {
                          ref.read(createIngredientProvider.notifier).setImageUrl(imageUrl);
                        }

                        final res = await ref.read(createIngredientProvider.notifier).updateIngredient();

                        if (res && mounted) {
                          ref.read(createIngredientProvider.notifier).reset();
                          context.pop();
                        }
                      },
                child: state.isLoadingNutrition
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Update Ingredient',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => _showDeleteConfirmation(context, ref),
                child: const Text('Delete Ingredient', 
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext outerContext, WidgetRef ref) {
    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Ingredient', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this ingredient? This action will archive it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref.read(createIngredientProvider.notifier).deleteIngredient(widget.ingredientId);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext); // Close dialog
              }
              if (success && outerContext.mounted) {
                ref.read(createIngredientProvider.notifier).reset();
                outerContext.pop(); // Go back to list safely
                ScaffoldMessenger.of(outerContext).showSnackBar(
                  const SnackBar(content: Text('Ingredient deleted'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87));
  }

  Widget _buildThemedTextField({required TextEditingController controller, required String hint, Function(String)? onChanged, int? maxLines}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines ?? 1,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildThemedDropdown(dynamic state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.category,
          isExpanded: true,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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

  Widget _buildSegmentedToggle<T>({required String label, required T value, required List<ButtonSegment<T>> segments, required Function(T) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            segments: segments,
            selected: {value},
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              selectedBackgroundColor: AppColors.rosePink,
              selectedForegroundColor: Colors.white,
              side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSelectionChanged: (set) => onChanged(set.first),
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
              fillColor: Colors.white,
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
        color: AppColors.cardRose.withValues(alpha: 0.2),
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

  Widget _buildNutritionToggle(dynamic state) {
    return _buildSegmentedToggle<String>(
      label: 'Input Method',
      value: state.nutritionMethod,
      segments: const [
        ButtonSegment(value: 'manual', label: Text('Manual')),
        ButtonSegment(value: 'ai', label: Text('AI SmartFill')),
      ],
      onChanged: (val) => ref.read(createIngredientProvider.notifier).setNutritionMethod(val),
    );
  }
}
