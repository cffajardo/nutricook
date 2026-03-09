import 'package:flutter/material.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/services/tag_service.dart';

class RecipeTagsFilterModal extends StatefulWidget {
  final String title;
  const RecipeTagsFilterModal({super.key, required this.title});

  @override
  State<RecipeTagsFilterModal> createState() => _RecipeTagsFilterModalState();
}

class _RecipeTagsFilterModalState extends State<RecipeTagsFilterModal> {
  final TagService _tagService = TagService();
  final TextEditingController _tagSearchController = TextEditingController();
  String _sortBy = 'Popularity';
  String _selectedCategoryId = 'difficulty';

  String _query = '';
  final Set<String> _selectedTags = {};

  static final List<String> _allTags = <String>[
    ...RecipeTags.difficulty,
    ...RecipeTags.cuisine,
    ...RecipeTags.dietary,
    ...RecipeTags.nutrition,
  ];

  static const List<Map<String, String>> _categoryOptions =
      <Map<String, String>>[
        {'id': 'difficulty', 'name': 'Difficulty'},
        {'id': 'cuisine', 'name': 'Cuisine'},
        {'id': 'dietary', 'name': 'Dietary'},
        {'id': 'nutrition', 'name': 'Nutrition'},
      ];

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
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
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

                  const SizedBox(height: 12),

                  _buildCategorySelector(),

                  const SizedBox(height: 24),

                  _buildTagPills(),
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
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.rosePink,
              size: 32,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        onChanged: (value) {
          setState(() {
            _query = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search tags...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.rosePink,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.cardRose.withValues(alpha: 0.3),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: AppColors.rosePink.withValues(alpha: 0.15),
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

  Widget _buildSortTrigger() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _sortBy = value),
      itemBuilder: (context) => [
        'Popularity',
        'A-Z',
        'Recent',
      ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sort by: $_sortBy',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.rosePink,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildClearAllButton() {
    return TextButton(
      onPressed: () => setState(() => _selectedTags.clear()),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
      ),
      child: const Text(
        'Clear all',
        style: TextStyle(
          color: AppColors.rosePink,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
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
            color: isSelected
                ? AppColors.rosePink
                : AppColors.rosePink.withValues(alpha: 0.2),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Apply Selection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTagPills() {
    return StreamBuilder<List<String>>(
      stream: _tagService.getTagNamesByCategory(_selectedCategoryId),
      builder: (context, snapshot) {
        final categoryTags =
            snapshot.data ?? _fallbackCategoryTags(_selectedCategoryId);
        final filteredCategory = _filteredTagsFrom(categoryTags);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Tags',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (filteredCategory.isEmpty)
              const Text(
                'No tags in this category.',
                style: TextStyle(color: Colors.black45),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: filteredCategory
                    .map((tag) => _buildTagPill(tag))
                    .toList(),
              ),

            const SizedBox(height: 18),

            Text(
              'General Tags',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            StreamBuilder<List<String>>(
              stream: _tagService.getUncategorizedTagNames(),
              builder: (context, generalSnapshot) {
                final generalTags = generalSnapshot.data ?? <String>[];
                final filteredGeneral = _filteredTagsFrom(generalTags);

                if (filteredGeneral.isEmpty) {
                  return const Text(
                    'No uncategorized tags.',
                    style: TextStyle(color: Colors.black45),
                  );
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: filteredGeneral
                      .map((tag) => _buildTagPill(tag))
                      .toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categoryOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _categoryOptions[index];
          final id = item['id']!;
          final name = item['name']!;
          final selected = _selectedCategoryId == id;

          return ChoiceChip(
            label: Text(name),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedCategoryId = id;
              });
            },
            selectedColor: AppColors.rosePink,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: AppColors.rosePink.withValues(alpha: 0.2),
              width: 1.2,
            ),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }

  List<String> _fallbackCategoryTags(String categoryId) {
    switch (categoryId) {
      case 'difficulty':
        return RecipeTags.difficulty;
      case 'cuisine':
        return RecipeTags.cuisine;
      case 'dietary':
        return RecipeTags.dietary;
      case 'nutrition':
        return RecipeTags.nutrition;
      default:
        return _allTags;
    }
  }

  List<String> _filteredTagsFrom(List<String> source) {
    final normalized = source
        .map((tag) => tag.trim().toLowerCase())
        .toSet()
        .toList();

    final filtered = normalized
        .where((tag) => _query.isEmpty || tag.contains(_query))
        .toList();

    if (_sortBy == 'A-Z') {
      filtered.sort((a, b) => a.compareTo(b));
    }

    return filtered;
  }
}
