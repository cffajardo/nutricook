import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class RecipeTagsFilterModal extends StatefulWidget {
  final String title; 
  const RecipeTagsFilterModal({super.key, required this.title});

  @override
  State<RecipeTagsFilterModal> createState() => _RecipeTagsFilterModalState();
}

class _RecipeTagsFilterModalState extends State<RecipeTagsFilterModal> {
  final TextEditingController _tagSearchController = TextEditingController();
  String _sortBy = 'Popularity';
  
  final List<String> _allTags = [
    'Vegan', 'Gluten-Free', 'Dairy-Free', 'Keto', 'Low-Carb', 
    'Nut-Free', 'High-Protein', 'Vegetarian', 'Pescatarian', 'Paleo',
    'Low-Sugar', 'Organic', 'Quick', 'Budget'
  ];
  
  final Set<String> _selectedTags = {};

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
          const SizedBox(height: 12),
          Container(
            width: 40, height: 5,
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
          ),
          
          _buildHeader(),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTagSearchField(),
                  
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSortTrigger(),
                      if (_selectedTags.isNotEmpty) _buildClearAllButton(),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _allTags.map((tag) => _buildTagPill(tag)).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: AppColors.rosePink, size: 32),
          ),
          Expanded(
            child: Center(
              child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTagSearchField() {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _tagSearchController,
        decoration: InputDecoration(
          hintText: 'Search tags...',
          prefixIcon: const Icon(Icons.search, color: AppColors.rosePink, size: 20),
          filled: true,
          fillColor: AppColors.cardRose.withValues(alpha: 0.3),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.15), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSortTrigger() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _sortBy = value),
      itemBuilder: (context) => ['Popularity', 'A-Z', 'Recent']
          .map((s) => PopupMenuItem(value: s, child: Text(s)))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sort by: $_sortBy',
            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.rosePink, size: 20),
        ],
      ),
    );
  }

  Widget _buildClearAllButton() {
    return TextButton(
      onPressed: () => setState(() => _selectedTags.clear()),
      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
      child: const Text(
        'Clear all',
        style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildTagPill(String tag) {
    final isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected ? _selectedTags.remove(tag) : _selectedTags.add(tag);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rosePink : Colors.white,
          borderRadius: BorderRadius.circular(25), 
          border: Border.all(
            color: isSelected ? AppColors.rosePink : AppColors.rosePink.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context, _selectedTags.toList()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('Apply Selection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}