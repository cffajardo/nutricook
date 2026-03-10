import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/library/units/unit_provider.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';

class AddIngredientModal extends ConsumerStatefulWidget {
  final ValueChanged<RecipeIngredient> onIngredientAdded;
  final VoidCallback? onIngredientDeleted;
  final RecipeIngredient? initialIngredient;

  const AddIngredientModal({
    super.key,
    required this.onIngredientAdded,
    this.onIngredientDeleted,
    this.initialIngredient,
  });

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
      _amountController = TextEditingController(text: _formatQuantity(initial.quantity));
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
          const Expanded(
            child: Center(
              child: Text(
                'Add Ingredient',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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

    return GridView.builder(
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
    );
  }

  Widget _buildIngredientSelectionStep() {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final query = _searchController.text.trim().toLowerCase();

    return ingredientsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Failed to load ingredients: $error')),
      data: (ingredients) {
        final filtered = ingredients.where((ingredient) {
          final inCategory =
              _selectedCategory == null ||
              ingredient.category.toLowerCase() == _selectedCategory!.toLowerCase();
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          onTap: () => setState(() {
                            _selectedIngredientId = ingredient.id;
                            _selectedIngredientName = ingredient.name;
                            _stage = 2;
                          }),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailForm() {
    final isEditing = widget.initialIngredient != null;
    final unitsAsync = ref.watch(unitsProvider);

    return unitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Failed to load units: $error')),
      data: (units) {
        if (units.isEmpty) {
          return const Center(child: Text('No units found.'));
        }

        _selectedUnitId ??= _resolveInitialUnitId(units);
        final selectedUnit = _findUnitById(units, _selectedUnitId) ?? units.first;

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
                onChanged: (value) => setState(() => _selectedProcess = value ?? 'None'),
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
                      units: units,
                      selectedUnitId: selectedUnit.id,
                    ),
                  ),
                ],
              ),
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
                          side: const BorderSide(color: Colors.redAccent, width: 1.5),
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
  }

  void _submitIngredient(Unit selectedUnit) {
    final ingredientId = _selectedIngredientId;
    final ingredientName = _selectedIngredientName;
    final quantity = double.tryParse(_amountController.text.trim());

    if (ingredientId == null || ingredientName == null || ingredientName.isEmpty) {
      _showSnack('Please select an ingredient.');
      return;
    }
    if (quantity == null || quantity <= 0) {
      _showSnack('Please enter a valid quantity.');
      return;
    }

    widget.onIngredientAdded(
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
          prefixIcon: const Icon(Icons.search, color: AppColors.rosePink, size: 20),
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
              .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
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
            child: const Icon(Icons.restaurant_outlined, color: AppColors.rosePink),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            maxLines: 1,
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
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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

    final gramLike = units.where((unit) =>
        unit.id.toLowerCase() == 'g' || unit.name.toLowerCase() == 'g');
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
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
