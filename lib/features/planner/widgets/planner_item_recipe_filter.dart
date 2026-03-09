import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/widgets/recipe_tags_filter.dart';

class PlannerRecipeFilterModal extends StatefulWidget {
  const PlannerRecipeFilterModal({super.key});

  @override
  State<PlannerRecipeFilterModal> createState() => _PlannerRecipeFilterModalState();
}

class _PlannerRecipeFilterModalState extends State<PlannerRecipeFilterModal> {
  late TextEditingController _calController, _carbController, _fatController, 
       _proController, _sugarController, _fiberController, _sodiumController, _timeController;

  double _calories = 500, _carbs = 50, _fats = 30, _protein = 40, 
         _sugar = 20, _fiber = 10, _sodium = 500, _cookTime = 30;

  @override
  void initState() {
    super.initState();
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
    for (var c in [_calController, _carbController, _fatController, _proController, 
                  _sugarController, _fiberController, _sodiumController, _timeController]) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateMetric(String type, double value) {
    setState(() {
      final valStr = value.round().toString();
      switch (type) {
        case 'Calories': _calories = value; _calController.text = valStr; break;
        case 'Carbs': _carbs = value; _carbController.text = valStr; break;
        case 'Fats': _fats = value; _fatController.text = valStr; break;
        case 'Protein': _protein = value; _proController.text = valStr; break;
        case 'Sugar': _sugar = value; _sugarController.text = valStr; break;
        case 'Fiber': _fiber = value; _fiberController.text = valStr; break;
        case 'Sodium': _sodium = value; _sodiumController.text = valStr; break;
        case 'Time': _cookTime = value; _timeController.text = valStr; break;
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
                        _buildInputSliderRow('Calories', _calories, 2000, _calController, unit: 'kcal'),
                        _buildInputSliderRow('Protein', _protein, 150, _proController),
                        _buildInputSliderRow('Carbs', _carbs, 200, _carbController),
                        _buildInputSliderRow('Fats', _fats, 100, _fatController),
                        _buildInputSliderRow('Sugar', _sugar, 100, _sugarController),
                        _buildInputSliderRow('Fiber', _fiber, 50, _fiberController),
                        _buildInputSliderRow('Sodium', _sodium, 2500, _sodiumController, unit: 'mg'),
                      ],
                    ),
                    _buildExpansionCategory(
                      title: 'Cook Time',
                      icon: Icons.timer_outlined,
                      children: [
                        _buildInputSliderRow('Time', _cookTime, 180, _timeController, unit: 'min'),
                      ],
                    ),
                    _buildExpansionCategory(
                      title: 'Tags & Preferences',
                      icon: Icons.sell_outlined,
                      children: [
                        _buildTagActionRow('Exclude'),
                        _buildTagActionRow('Include'),
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

  Widget _buildExpansionCategory({required String title, required IconData icon, required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.rosePink),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black87)),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: children,
      ),
    );
  }

  Widget _buildInputSliderRow(String label, double value, double max, TextEditingController controller, {String unit = 'g'}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
            SizedBox(
              width: 85,
              height: 35,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.rosePink, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardRose.withValues(alpha: 0.3),
                  contentPadding: EdgeInsets.zero,
                  suffixText: '$unit ',
                  suffixStyle: const TextStyle(fontSize: 10, color: Colors.black26),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.2), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
                  ),
                ),
                onChanged: (text) {
                  final val = double.tryParse(text) ?? 0;
                  if (val <= max) setState(() => _updateMetric(label, val));
                },
              ),
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
            onChanged: (v) => _updateMetric(label, v),
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
          const Text('Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          IconButton(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(Icons.close_rounded, color: Colors.black54)
          ),
        ],
      ),
    );
  }

  Widget _buildTagActionRow(String label) {
    return ListTile(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RecipeTagsFilterModal(title: '$label Tags'),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.rosePink),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}