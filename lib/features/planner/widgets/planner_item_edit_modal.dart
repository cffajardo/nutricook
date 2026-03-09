import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/widgets/planner_item_datepicker_modal.dart';
import 'package:nutricook/features/planner/widgets/planner_item_select_recipe.dart';

class PlannerItemEditModal extends ConsumerStatefulWidget {
  final dynamic recipe;
  const PlannerItemEditModal({super.key, this.recipe});

  @override
  ConsumerState<PlannerItemEditModal> createState() => _PlannerItemEditModalState();
}

class _PlannerItemEditModalState extends ConsumerState<PlannerItemEditModal> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMeal = 'Breakfast';
  String? _selectedRecipeName;
  
  static final DateFormat _dateFormatter = DateFormat('MMMM d, y');

  late TextEditingController _servingsController;
  late TextEditingController _notesController;

  static const List<String> _mealOptions = [
    'Breakfast', 'Lunch', 'Snack', 'Dinner', 'Other',
  ];

  @override
  void initState() {
    super.initState();

    final dynamic incomingData = widget.recipe;
    final Map? data = (incomingData is Map) ? incomingData : null;

    _selectedDate = data?['date'] ?? DateTime.now();
    _selectedMeal = data?['mealTime'] ?? 'Breakfast';
    _selectedRecipeName = data?['name'];

    _servingsController = TextEditingController(
      text: data?['servings']?.toString() ?? '1',
    );
    _notesController = TextEditingController(text: data?['notes'] ?? '');
  }

  @override
  void dispose() {
    _servingsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const _DragHandle(),
              _buildHeader(),
              const Divider(height: 1),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildPlanForSection(),
                    const SizedBox(height: 32),
                    _buildRecipeSection(),
                    const SizedBox(height: 32),
                    _buildNotesSection(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: AppColors.rosePink, size: 32),
          ),
          const Text('Plan meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.rosePink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanForSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Plan For'),
        _buildInputGroup([
          _buildStaticRow(
            'Date',
            _dateFormatter.format(_selectedDate),
            onTap: () async {
              final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PlannerDatePickModal(initialDate: _selectedDate),
              );

              if (pickedDate != null && mounted) {
                setState(() => _selectedDate = pickedDate);
              }
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildDropdownRow('Meal Time', _selectedMeal),
        ]),
      ],
    );
  }

  Widget _buildRecipeSection() {
    final String recipeDisplay = _selectedRecipeName ?? 
        ((widget.recipe is Map) ? (widget.recipe['name'] ?? 'Select Recipe...') : 'Select Recipe...');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Recipe'),
        _buildInputGroup([
          _buildStaticRow(
            'Recipe',
            recipeDisplay,
            onTap: () async {
              final selectedRecipe = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const PlannerRecipeSelectModal(),
              );

              if (selectedRecipe != null && mounted) {
                setState(() => _selectedRecipeName = selectedRecipe['name']);
              }
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildInputRow('Servings', _servingsController, isNumber: true),
        ]),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Notes'),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Enter any extra instructions...',
            hintStyle: const TextStyle(color: Colors.black26),
            filled: true,
            fillColor: AppColors.cardRose.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: AppColors.rosePink.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.rosePink,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          'Save',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInputGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.14), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildStaticRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text(value, style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.rosePink, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow(String label, String current) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: current,
            icon: const Icon(Icons.expand_more, color: AppColors.rosePink),
            underline: const SizedBox(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedMeal = val);
            },
            items: _mealOptions.map((m) => DropdownMenuItem(
              value: m, 
              child: Text(m, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(
            width: 80,
            height: 38,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.rosePink),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cardRose.withValues(alpha: 0.3),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.rosePink.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
                ),
                hintText: '1',
                hintStyle: const TextStyle(color: Colors.black12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 5,
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.rosePink),
      ),
    );
  }
}