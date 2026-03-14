import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/services/ingredient_service.dart';
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
  late TextEditingController _densityController;
  late TextEditingController _avgWeightController;

  final _imageUploadKey = GlobalKey();
  late Ingredient _ingredient;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  final List<String> categories = [
    'proteins', 'vegetables', 'fruits', 'dairy', 'grains', 'spices',
    'herbs', 'sauces', 'seafood', 'nuts-and-seeds', 'fats-and-oils', 'beverages',
  ];

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _caloriesController = TextEditingController();
    _carbsController = TextEditingController();
    _proteinController = TextEditingController();
    _fatController = TextEditingController();
    _fiberController = TextEditingController();
    _sugarController = TextEditingController();
    _sodiumController = TextEditingController();
    _densityController = TextEditingController();
    _avgWeightController = TextEditingController();

    // Initialize with first category as default
    _selectedCategory = categories.first;

    _loadIngredient();
  }

  Future<void> _loadIngredient() async {
    try {
      final service = IngredientService();
      final ingredient = await service.getIngredientById(widget.ingredientId);

      if (ingredient == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Ingredient not found';
          });
        }
        return;
      }

      setState(() {
        _ingredient = ingredient;
        _nameController.text = ingredient.name;
        _descriptionController.text = ingredient.description ?? '';
        
        // Ensure category is valid, otherwise use first category
        _selectedCategory = categories.contains(ingredient.category)
            ? ingredient.category
            : categories.first;

        if (ingredient.nutritionPer100g != null) {
          _caloriesController.text = ingredient.nutritionPer100g!.calories.toString();
          _carbsController.text = ingredient.nutritionPer100g!.carbohydrates.toString();
          _proteinController.text = ingredient.nutritionPer100g!.protein.toString();
          _fatController.text = ingredient.nutritionPer100g!.fat.toString();
          _fiberController.text = ingredient.nutritionPer100g!.fiber.toString();
          _sugarController.text = ingredient.nutritionPer100g!.sugar.toString();
          _sodiumController.text = ingredient.nutritionPer100g!.sodium.toStringAsFixed(2);
        }

        if (ingredient.densityGPerMl != null) {
          _densityController.text = ingredient.densityGPerMl!.toString();
        }

        if (ingredient.avgWeightG != null) {
          _avgWeightController.text = ingredient.avgWeightG!.toString();
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading ingredient: $e';
        });
      }
    }
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
    _densityController.dispose();
    _avgWeightController.dispose();
    super.dispose();
  }

  void _updateIngredient() {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showError('Ingredient name is required');
      return;
    }

    if (_selectedCategory.isEmpty) {
      _showError('Category is required');
      return;
    }

    // Validate numeric fields
    final calories = int.tryParse(_caloriesController.text);
    final carbs = double.tryParse(_carbsController.text);
    final protein = double.tryParse(_proteinController.text);
    final fat = double.tryParse(_fatController.text);
    final fiber = double.tryParse(_fiberController.text);
    final sugar = double.tryParse(_sugarController.text);
    final sodium = double.tryParse(_sodiumController.text);
    final density = _densityController.text.isNotEmpty ? double.tryParse(_densityController.text) : null;
    final avgWeight = _avgWeightController.text.isNotEmpty ? double.tryParse(_avgWeightController.text) : null;

    if (calories == null || carbs == null || protein == null || fat == null ||
        fiber == null || sugar == null || sodium == null) {
      _showError('All nutrition values must be valid numbers');
      return;
    }

    // Validate physical properties
    if (_ingredient.densityGPerMl != null && density == null) {
      _showError('Density value is required for this ingredient');
      return;
    }

    if (_ingredient.avgWeightG != null && avgWeight == null) {
      _showError('Average weight value is required for this ingredient');
      return;
    }

    _saveIngredient(calories, carbs, protein, fat, fiber, sugar, sodium, density, avgWeight);
  }

  Future<void> _saveIngredient(
    int calories,
    double carbs,
    double protein,
    double fat,
    double fiber,
    double sugar,
    double sodium,
    double? density,
    double? avgWeight,
  ) async {
    setState(() => _isSaving = true);

    try {
      // Upload image if selected
      String? imageUrl = _ingredient.imageURL;
      final uploadedUrl = await (_imageUploadKey.currentState as dynamic)?.uploadImage();
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }

      // Create updated ingredient
      final nutritionInfo = NutritionInfo(
        calories: calories,
        carbohydrates: carbs,
        protein: protein,
        fat: fat,
        fiber: fiber,
        sugar: sugar,
        sodium: sodium,
      );

      final updatedIngredient = _ingredient.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        nutritionPer100g: nutritionInfo,
        densityGPerMl: density,
        avgWeightG: avgWeight,
        imageURL: imageUrl,
      );

      // Update in database
      final service = IngredientService();
      await service.updateIngredient(updatedIngredient);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showError('Failed to save ingredient: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _errorMessage = null);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.rosePink),
        ),
      );
    }

    if (_errorMessage != null && _errorMessage!.contains('not found')) {
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
        body: Center(
          child: Text(_errorMessage ?? 'Error loading ingredient'),
        ),
      );
    }

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
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Description'),
            const SizedBox(height: 12),
            _buildThemedTextField(
              controller: _descriptionController,
              hint: 'Optional description',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

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
                initialImageUrl: _ingredient.imageURL,
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Category'),
            const SizedBox(height: 12),
            _buildThemedDropdown(),
            const SizedBox(height: 24),

            _buildSectionHeader('Nutrition (per 100g)'),
            const SizedBox(height: 12),
            _buildManualNutritionGrid(),
            const SizedBox(height: 24),

            _buildSectionHeader('Physical Properties'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Density (g/mL)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      _buildThemedTextField(
                        controller: _densityController,
                        hint: 'e.g., 1.0',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avg Weight (g)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      _buildThemedTextField(
                        controller: _avgWeightController,
                        hint: 'e.g., 200',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                onPressed: _isSaving ? null : _updateIngredient,
                child: Text(
                  _isSaving ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- THEMED UI COMPONENTS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
    );
  }

  Widget _buildThemedTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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

  Widget _buildThemedDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory.isEmpty ? categories.first : _selectedCategory,
          isExpanded: true,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c.replaceAll('-', ' ').toUpperCase())))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedCategory = val);
            }
          },
        ),
      ),
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
        Text(
          '$label ($unit)',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45),
        ),
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
}
