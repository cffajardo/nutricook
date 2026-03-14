import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_tags_filter.dart';

class PlannerRecipeFilterModal extends ConsumerStatefulWidget {
  const PlannerRecipeFilterModal({super.key});

  @override
  ConsumerState<PlannerRecipeFilterModal> createState() =>
      _PlannerRecipeFilterModalState();
}

class _PlannerRecipeFilterModalState
    extends ConsumerState<PlannerRecipeFilterModal> {
  late TextEditingController _calController,
      _carbController,
      _fatController,
      _proController,
      _sugarController,
      _fiberController,
      _sodiumController,
      _timeController;

  double _calories = 500,
      _carbs = 50,
      _fats = 30,
      _protein = 40,
      _sugar = 20,
      _fiber = 10,
      _sodium = 500,
      _cookTime = 30;
  bool _useCalories = false,
      _useCarbs = false,
      _useFats = false,
      _useProtein = false,
      _useSugar = false,
      _useFiber = false,
      _useSodium = false;
  bool _caloriesComparisonMode = false,
      _carbsComparisonMode = false,
      _fatsComparisonMode = false,
      _proteinComparisonMode = false,
      _sugarComparisonMode = false,
      _fiberComparisonMode = false,
      _sodiumComparisonMode = false;
  Set<String> _includeTags = <String>{};
  Set<String> _excludeTags = <String>{};

  @override
  void initState() {
    super.initState();
    final filters = ref.read(recipeAdvancedFiltersProvider);
    _calories = filters.maxCalories;
    _carbs = filters.maxCarbs;
    _fats = filters.maxFats;
    _protein = filters.maxProtein;
    _sugar = filters.maxSugar;
    _fiber = filters.maxFiber;
    _sodium = filters.maxSodium;
    _useCalories = filters.useCaloriesFilter;
    _useCarbs = filters.useCarbsFilter;
    _useFats = filters.useFatsFilter;
    _useProtein = filters.useProteinFilter;
    _useSugar = filters.useSugarFilter;
    _useFiber = filters.useFiberFilter;
    _useSodium = filters.useSodiumFilter;
    _caloriesComparisonMode = filters.caloriesComparisonMode;
    _carbsComparisonMode = filters.carbsComparisonMode;
    _fatsComparisonMode = filters.fatsComparisonMode;
    _proteinComparisonMode = filters.proteinComparisonMode;
    _sugarComparisonMode = filters.sugarComparisonMode;
    _fiberComparisonMode = filters.fiberComparisonMode;
    _sodiumComparisonMode = filters.sodiumComparisonMode;
    _cookTime = filters.maxCookTimeMinutes;
    _includeTags = filters.includeTags.toSet();
    _excludeTags = filters.excludeTags.toSet();

    _calController = TextEditingController(text: _calories.round().toString());
    _carbController = TextEditingController(text: _carbs.round().toString());
    _fatController = TextEditingController(text: _fats.round().toString());
    _proController = TextEditingController(text: _protein.round().toString());
    _sugarController = TextEditingController(text: _sugar.round().toString());
    _fiberController = TextEditingController(text: _fiber.round().toString());
    _sodiumController = TextEditingController(text: _sodium.round().toString());
    _timeController = TextEditingController(text: _cookTime.round().toString());
  }

  @override
  void dispose() {
    for (var c in [
      _calController,
      _carbController,
      _fatController,
      _proController,
      _sugarController,
      _fiberController,
      _sodiumController,
      _timeController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateMetric(String type, double value) {
    setState(() {
      final valStr = value.round().toString();
      switch (type) {
        case 'Calories':
          _calories = value;
          _calController.text = valStr;
          break;
        case 'Carbs':
          _carbs = value;
          _carbController.text = valStr;
          break;
        case 'Fats':
          _fats = value;
          _fatController.text = valStr;
          break;
        case 'Protein':
          _protein = value;
          _proController.text = valStr;
          break;
        case 'Sugar':
          _sugar = value;
          _sugarController.text = valStr;
          break;
        case 'Fiber':
          _fiber = value;
          _fiberController.text = valStr;
          break;
        case 'Sodium':
          _sodium = value;
          _sodiumController.text = valStr;
          break;
        case 'Time':
          _cookTime = value;
          _timeController.text = valStr;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildFilterHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    _buildExpansionCategory(
                      title: 'Nutrition',
                      icon: Icons.analytics_outlined,
                      children: [
                        _buildInputSliderRow(
                          'Calories',
                          _calories,
                          2000,
                          _calController,
                          unit: 'kcal',
                          enabled: _useCalories,
                          onToggle: (enabled) =>
                              setState(() => _useCalories = enabled),
                          comparisonMode: _caloriesComparisonMode,
                          onComparisonModeChanged: (mode) =>
                              setState(() => _caloriesComparisonMode = mode),
                        ),
                        _buildInputSliderRow(
                          'Protein',
                          _protein,
                          150,
                          _proController,
                          enabled: _useProtein,
                          onToggle: (enabled) =>
                              setState(() => _useProtein = enabled),
                          comparisonMode: _proteinComparisonMode,
                          onComparisonModeChanged: (mode) =>
                              setState(() => _proteinComparisonMode = mode),
                        ),
                        _buildInputSliderRow(
                          'Carbs',
                          _carbs,
                          200,
                          _carbController,
                          enabled: _useCarbs,
                          onToggle: (enabled) =>
                              setState(() => _useCarbs = enabled),
                          comparisonMode: _carbsComparisonMode,
                          onComparisonModeChanged: (mode) =>
                              setState(() => _carbsComparisonMode = mode),
                        ),
                        _buildInputSliderRow(
                          'Fats',
                          _fats,
                          100,
                          _fatController,
                          enabled: _useFats,
                          onToggle: (enabled) =>
                              setState(() => _useFats = enabled),
                          comparisonMode: _fatsComparisonMode,
                          onComparisonModeChanged: (mode) =>
                              setState(() => _fatsComparisonMode = mode),
                        ),
                        _buildInputSliderRow(
                          'Sugar',
                          _sugar,
                          100,
                          _sugarController,
                          enabled: _useSugar,
                          onToggle: (enabled) =>
                              setState(() => _useSugar = enabled),
                          comparisonMode: _sugarComparisonMode,
                          onComparisonModeChanged: (mode) =>
                              setState(() => _sugarComparisonMode = mode),
                        ),
                        _buildInputSliderRow(
                          'Fiber',
                          _fiber,
                          50,
                          _fiberController,
                          enabled: _useFiber,
                          onToggle: (enabled) =>
                              setState(() => _useFiber = enabled),
                          comparisonMode: _fiberComparisonMode,
                          onComparisonModeChanged: (mode) =>
                              setState(() => _fiberComparisonMode = mode),
                        ),
                        _buildInputSliderRow(
                          'Sodium',
                          _sodium,
                          2500,
                          _sodiumController,
                          unit: 'mg',
                          enabled: _useSodium,
                          onToggle: (enabled) =>
                              setState(() => _useSodium = enabled),
                          comparisonMode: _sodiumComparisonMode,
                          onComparisonModeChanged: (mode) =>
                              setState(() => _sodiumComparisonMode = mode),
                        ),
                      ],
                    ),
                    _buildExpansionCategory(
                      title: 'Cook Time',
                      icon: Icons.timer_outlined,
                      children: [
                        _buildInputSliderRow(
                          'Time',
                          _cookTime,
                          180,
                          _timeController,
                          unit: 'min',
                        ),
                      ],
                    ),
                    _buildExpansionCategory(
                      title: 'Tags & Preferences',
                      icon: Icons.sell_outlined,
                      children: [
                        _buildTagActionRow(
                          label: 'Exclude',
                          selectedCount: _excludeTags.length,
                          currentSelection: _excludeTags,
                          onUpdated: (next) =>
                              setState(() => _excludeTags = next.toSet()),
                        ),
                        _buildTagActionRow(
                          label: 'Include',
                          selectedCount: _includeTags.length,
                          currentSelection: _includeTags,
                          onUpdated: (next) =>
                              setState(() => _includeTags = next.toSet()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionCategory({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.rosePink),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        children: children,
      ),
    );
  }

  Widget _buildInputSliderRow(
    String label,
    double value,
    double max,
    TextEditingController controller, {
    String unit = 'g',
    bool? enabled,
    ValueChanged<bool>? onToggle,
    bool comparisonMode = false,
    ValueChanged<bool>? onComparisonModeChanged,
  }) {
    final isToggleable = enabled != null && onToggle != null;
    final isEnabled = enabled ?? true;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (isToggleable)
                  Checkbox(
                    value: isEnabled,
                    onChanged: (v) => onToggle(v ?? false),
                    activeColor: AppColors.rosePink,
                  ),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isEnabled ? Colors.black54 : Colors.black26,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (isEnabled && onComparisonModeChanged != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.rosePink.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => onComparisonModeChanged(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: !comparisonMode
                                    ? AppColors.rosePink.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(6),
                                ),
                              ),
                              child: Text(
                                '<',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: !comparisonMode
                                      ? AppColors.rosePink
                                      : Colors.black26,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onComparisonModeChanged(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: comparisonMode
                                    ? AppColors.rosePink.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(6),
                                ),
                              ),
                              child: Text(
                                '>',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: comparisonMode
                                      ? AppColors.rosePink
                                      : Colors.black26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Opacity(
                  opacity: isEnabled ? 1 : 0.6,
                  child: SizedBox(
                    width: 85,
                    height: 35,
                    child: TextField(
                      controller: controller,
                      enabled: isEnabled,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.rosePink,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.cardRose.withValues(alpha: 0.3),
                        contentPadding: EdgeInsets.zero,
                        suffixText: '$unit ',
                        suffixStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.black26,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.rosePink.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.rosePink,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: isEnabled
                          ? (text) {
                              final val = double.tryParse(text) ?? 0;
                              if (val <= max)
                                setState(() => _updateMetric(label, val));
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.rosePink,
            inactiveTrackColor: AppColors.cardRose,
            thumbColor: AppColors.rosePink,
            overlayColor: AppColors.rosePink.withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 2,
          ),
          child: Slider(
            value: value.clamp(0.0, max),
            min: 0,
            max: max,
            onChanged: isEnabled ? (v) => _updateMetric(label, v) : null,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTagActionRow({
    required String label,
    required int selectedCount,
    required Set<String> currentSelection,
    required ValueChanged<List<String>> onUpdated,
  }) {
    return ListTile(
      onTap: () async {
        final selected = await showModalBottomSheet<List<String>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RecipeTagsFilterModal(
            title: '$label Tags',
            initialSelectedTags: currentSelection.toList(),
          ),
        );

        if (selected != null) {
          onUpdated(selected);
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: selectedCount > 0
          ? Text(
              '$selectedCount selected',
              style: const TextStyle(fontSize: 12),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.rosePink,
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ref.read(recipeAdvancedFiltersProvider.notifier).reset();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: BorderSide(
                  color: AppColors.rosePink.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: AppColors.rosePink,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(recipeAdvancedFiltersProvider.notifier)
                    .apply(
                      RecipeAdvancedFilters(
                        maxCalories: _calories,
                        maxCarbs: _carbs,
                        maxFats: _fats,
                        maxProtein: _protein,
                        maxSugar: _sugar,
                        maxFiber: _fiber,
                        maxSodium: _sodium,
                        useCaloriesFilter: _useCalories,
                        useCarbsFilter: _useCarbs,
                        useFatsFilter: _useFats,
                        useProteinFilter: _useProtein,
                        useSugarFilter: _useSugar,
                        useFiberFilter: _useFiber,
                        useSodiumFilter: _useSodium,
                        caloriesComparisonMode: _caloriesComparisonMode,
                        carbsComparisonMode: _carbsComparisonMode,
                        fatsComparisonMode: _fatsComparisonMode,
                        proteinComparisonMode: _proteinComparisonMode,
                        sugarComparisonMode: _sugarComparisonMode,
                        fiberComparisonMode: _fiberComparisonMode,
                        sodiumComparisonMode: _sodiumComparisonMode,
                        maxCookTimeMinutes: _cookTime,
                        includeTags: _includeTags.toList(),
                        excludeTags: _excludeTags.toList(),
                      ),
                    );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rosePink,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
