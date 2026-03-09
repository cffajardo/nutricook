import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class AddIngredientModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onIngredientAdded;
  const AddIngredientModal({super.key, required this.onIngredientAdded});

  @override
  State<AddIngredientModal> createState() => _AddIngredientModalState();
}

class _AddIngredientModalState extends State<AddIngredientModal> {
  int _stage = 0; // 0: Categories, 1: Ingredients, 2: Details
  String? _selectedCat;
  String? _selectedItem;

  // Form State
  String _selectedProcess = 'Raw';
  String _selectedUnit = 'g';
  final TextEditingController _amountController = TextEditingController(text: '100');

  final List<String> _processes = ['Raw', 'Minced', 'Chopped', 'Diced', 'Sliced', 'Crushed'];
  final List<String> _units = ['g', 'kg', 'ml', 'tsp', 'tbsp', 'cup', 'pcs'];

  void _handleBack() {
    if (_stage > 0) {
      setState(() => _stage--);
    } else {
      Navigator.pop(context);
    }
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
            icon: Icon(_stage == 0 ? Icons.close : Icons.chevron_left, 
                 color: AppColors.rosePink, size: 28),
          ),
          const Expanded(
            child: Center(
              child: Text('Add Ingredient', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case 0: return _buildCategoryGrid();
      case 1: return _buildIngredientSearchStep(); // Now includes Search/Sort
      case 2: return _buildDetailForm();
      default: return Container();
    }
  }

  // STAGE 0: CATEGORIES
  Widget _buildCategoryGrid() {
    final cats = ['Protein', 'Veg', 'Dairy', 'Grains', 'Spices', 'Others'];
    return GridView.builder(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: cats.length,
      itemBuilder: (context, i) => _buildSelectionTile(
        label: cats[i],
        onTap: () => setState(() { _selectedCat = cats[i]; _stage = 1; }),
      ),
    );
  }

  // STAGE 1: INGREDIENTS WITH SEARCH & SORT
  Widget _buildIngredientSearchStep() {
    return Column(
      key: const ValueKey(1),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _buildSearchBar()),
              const SizedBox(width: 12),
              _buildSortButton(),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85,
            ),
            itemCount: 12,
            itemBuilder: (context, i) => _buildSelectionTile(
              label: '$_selectedCat $i',
              onTap: () => setState(() { _selectedItem = '$_selectedCat $i'; _stage = 2; }),
            ),
          ),
        ),
      ],
    );
  }

  // STAGE 2: REDESIGNED DETAIL FORM
  Widget _buildDetailForm() {
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDisplayField('Selected Ingredient', _selectedItem!, Icons.restaurant),
          const SizedBox(height: 20),
          
          // Process Dropdown
          const Text('Preparation Style', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildDropdownField(
            value: _selectedProcess,
            items: _processes,
            onChanged: (val) => setState(() => _selectedProcess = val!),
            icon: Icons.settings_suggest_outlined,
          ),
          
          const SizedBox(height: 24),
          
          const Text('Measurement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSmallTextField(controller: _amountController, hint: 'Amount'),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildDropdownField(
                  value: _selectedUnit,
                  items: _units,
                  onChanged: (val) => setState(() => _selectedUnit = val!),
                  icon: Icons.scale_outlined,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              widget.onIngredientAdded({
                'name': _selectedItem,
                'amount': _amountController.text,
                'unit': _selectedUnit,
                'process': _selectedProcess,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rosePink,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Add to Recipe', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  Widget _buildSearchBar() {
    return Container(
      height: 45,
      child:  TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, color: AppColors.rosePink, size: 20),
          filled: true,
          fillColor: AppColors.cardRose.withValues(alpha: 0.3),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
                  ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return Container(
      height: 45, width: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.2), width: 1.5),
      ),
      child: const Icon(Icons.sort_rounded, color: AppColors.rosePink, size: 22),
    );
  }

  Widget _buildDropdownField({
    required String value, 
    required List<String> items, 
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.2), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.rosePink),
          items: items.map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSmallTextField({required TextEditingController controller, required String hint}) {
    return Container(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          filled: true,
          fillColor: AppColors.cardRose.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
                  ),
        ),
      ),
    );
  }

  // Reusable Tile Component
  Widget _buildSelectionTile({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            height: 75, width: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.2), width: 1.5),
            ),
            child: const Icon(Icons.restaurant_outlined, color: AppColors.rosePink),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildDisplayField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.rosePink),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 4, width: 40,
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
    );
  }
}