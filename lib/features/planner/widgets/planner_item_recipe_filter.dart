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
  late TextEditingController _calController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;
  late TextEditingController _proController;
  late TextEditingController _timeController;

  double _calories = 500;
  double _carbs = 50;
  double _fats = 30;
  double _protein = 40;
  double _cookTime = 30;

  @override
  void initState() {
    super.initState();
    _calController = TextEditingController(text: _calories.round().toString());
    _carbController = TextEditingController(text: _carbs.round().toString());
    _fatController = TextEditingController(text: _fats.round().toString());
    _proController = TextEditingController(text: _protein.round().toString());
    _timeController = TextEditingController(text: _cookTime.round().toString());
  }

  @override
  void dispose() {
    _calController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    _proController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _updateMetric(String type, double value) {
    setState(() {
      if (type == 'Calories') {
        _calories = value;
        _calController.text = value.round().toString();
      } else if (type == 'Carbs') {
        _carbs = value;
        _carbController.text = value.round().toString();
      } else if (type == 'Fats') {
        _fats = value;
        _fatController.text = value.round().toString();
      } else if (type == 'Protein') {
        _protein = value;
        _proController.text = value.round().toString();
      } else if (type == 'Time') {
        _cookTime = value;
        _timeController.text = value.round().toString();
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Nutrition'),
                    _buildInputSliderRow('Calories', _calories, 2000, _calController),
                    _buildInputSliderRow('Carbs', _carbs, 200, _carbController),
                    _buildInputSliderRow('Fats', _fats, 100, _fatController),
                    _buildInputSliderRow('Protein', _protein, 150, _proController),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('Tags'),
                    _buildTagActionRow('Exclude'),
                    _buildTagActionRow('Include'),
                    
                    const SizedBox(height: 32),
                    _buildSectionHeader('Cook Time'),
                    _buildInputSliderRow('Time', _cookTime, 180, _timeController, isTime: true),
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

  Widget _buildInputSliderRow(
  String label, 
  double value, 
  double max, 
  TextEditingController controller, 
  {bool isTime = false}
) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
          SizedBox(
            width: 75,
            height: 35,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontWeight: FontWeight.w900, 
                color: AppColors.rosePink, 
                fontSize: 14
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cardRose.withValues(alpha: 0.3),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.rosePink.withValues(alpha: 0.2), 
                    width: 1.5
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.rosePink, 
                    width: 1.5
                  ),
                ),
                suffixText: isTime ? '' : 'g ', 
                suffixStyle: const TextStyle(fontSize: 10, color: Colors.black26),
              ),
              onChanged: (text) {
                final val = double.tryParse(text) ?? 0;
                if (val <= max) {
                  setState(() {
                    if (label == 'Calories') _calories = val;
                    else if (label == 'Carbs') _carbs = val;
                    else if (label == 'Fats') _fats = val;
                    else if (label == 'Protein') _protein = val;
                    else if (label == 'Time') _cookTime = val;
                  });
                }
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
          trackHeight: 3,
        ),
        child: Slider(
          value: value.clamp(0.0, max),
          min: 0,
          max: max,
          onChanged: (v) => _updateMetric(label, v),
        ),
      ),
      const SizedBox(height: 12),
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
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rosePink, letterSpacing: 1.1)),
    );
  }

  Widget _buildTagActionRow(String label) {
  return InkWell(
    onTap: () async {
      final result = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => RecipeTagsFilterModal(title: '$label Tags'),
      );
      
      if (result != null) {
        // Handle selected tags 
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.rosePink),
        ],
      ),
    ),
  );
}

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}