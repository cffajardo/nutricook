import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/library_constants.dart';
import 'package:nutricook/features/library/providers/library_catalog_provider.dart';
import 'package:nutricook/features/library/screens/library_item_detail_page.dart';

class LibraryItemDetailScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String subCategoryId;

  const LibraryItemDetailScreen({
    super.key,
    required this.categoryId,
    required this.subCategoryId,
  });

  @override
  ConsumerState<LibraryItemDetailScreen> createState() =>
      _LibraryItemDetailScreenState();
}

class _LibraryItemDetailScreenState
    extends ConsumerState<LibraryItemDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = LibrarySortBy.nameAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = libraryCategoryById(widget.categoryId);
    final subCategory = librarySubCategoryById(
      categoryId: widget.categoryId,
      subCategoryId: widget.subCategoryId,
    );

    final title = subCategory?.label ?? category?.label ?? 'Library';
    final itemsAsync = ref.watch(
      libraryItemsProvider(
        LibraryCatalogQuery(
          categoryId: widget.categoryId,
          subCategoryId: widget.subCategoryId,
          searchQuery: _searchQuery,
          sortBy: _sortBy,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndSort(title),
          const Divider(height: 1),
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error),
              data: (items) {
                if (items.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildItemTile(items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Search $title...',
              prefixIcon: const Icon(Icons.search, color: AppColors.rosePink),
              filled: true,
              fillColor: AppColors.cardRose.withValues(alpha: 0.2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.rosePink.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.rosePink,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardRose.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.rosePink.withValues(alpha: 0.1),
                      width: 1.2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.rosePink,
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: LibrarySortBy.nameAsc,
                          child: Text('Name (A-Z)'),
                        ),
                        DropdownMenuItem<String>(
                          value: LibrarySortBy.nameDesc,
                          child: Text('Name (Z-A)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _sortBy = value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(LibraryCatalogItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LibrarySingleItemDetailScreen(
              categoryId: widget.categoryId,
              itemId: item.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            _buildLeadingVisual(item.imageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black12,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingVisual(String? imageUrl) {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, _, _) {
            return _buildFallbackIcon();
          },
        ),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.restaurant, color: AppColors.rosePink, size: 24),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No items found for this subcategory.',
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black45),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Failed to load items: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
