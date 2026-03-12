import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/library/library_constants.dart';
import 'package:nutricook/features/library/nutrition/nutrition_provider.dart';
import 'package:nutricook/features/library/techniques/technique_provider.dart';
import 'package:nutricook/features/library/units/unit_provider.dart';

class LibrarySortBy {
  static const nameAsc = 'name_asc';
  static const nameDesc = 'name_desc';
}

class LibraryCatalogQuery {
  const LibraryCatalogQuery({
    required this.categoryId,
    required this.subCategoryId,
    this.searchQuery = '',
    this.sortBy = LibrarySortBy.nameAsc,
  });

  final String categoryId;
  final String subCategoryId;
  final String searchQuery;
  final String sortBy;

  @override
  bool operator ==(Object other) {
    return other is LibraryCatalogQuery &&
        other.categoryId == categoryId &&
        other.subCategoryId == subCategoryId &&
        other.searchQuery == searchQuery &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode =>
      Object.hash(categoryId, subCategoryId, searchQuery, sortBy);
}

class LibraryCatalogItem {
  const LibraryCatalogItem({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String? imageUrl;
}

List<LibraryCatalogItem> _sortedItems(
  List<LibraryCatalogItem> items,
  String sortBy,
) {
  items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  if (sortBy == LibrarySortBy.nameDesc) {
    return items.reversed.toList();
  }
  return items;
}

final libraryCategoriesProvider = Provider<List<LibraryCategoryDef>>((ref) {
  return kLibraryCategories;
});

final librarySubCategoriesProvider =
    Provider.family<List<LibrarySubCategoryDef>, String>((ref, categoryId) {
      return kLibrarySubCategoriesByCategory[categoryId] ??
          const <LibrarySubCategoryDef>[];
    });

final libraryItemsProvider =
    FutureProvider.family<List<LibraryCatalogItem>, LibraryCatalogQuery>((
      ref,
      query,
    ) async {
      final normalizedQuery = query.searchQuery.trim().toLowerCase();

      if (query.categoryId == LibraryCategoryIds.ingredients) {
        final ingredients = await ref.watch(ingredientsProvider.future);
        final filtered = ingredients.where((ingredient) {
          final matchesSubCategory = ingredient.category == query.subCategoryId;
          if (!matchesSubCategory) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return ingredient.name.toLowerCase().contains(normalizedQuery);
        });

        final items = filtered
            .map(
              (ingredient) => LibraryCatalogItem(
                id: ingredient.id,
                name: ingredient.name,
                description: ingredient.description?.trim().isNotEmpty == true
                    ? ingredient.description!.trim()
                    : 'No description available.',
                imageUrl: ingredient.imageURL,
              ),
            )
            .toList();
        return _sortedItems(items, query.sortBy);
      }

      if (query.categoryId == LibraryCategoryIds.techniques) {
        final techniques = await ref.watch(techniquesProvider.future);
        final filtered = techniques.where((technique) {
          final matchesSubCategory = technique.category == query.subCategoryId;
          if (!matchesSubCategory) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return technique.name.toLowerCase().contains(normalizedQuery);
        });

        final items = filtered
            .map(
              (technique) => LibraryCatalogItem(
                id: technique.id,
                name: technique.name,
                description: technique.description?.trim().isNotEmpty == true
                    ? technique.description!.trim()
                    : 'No description available.',
                imageUrl: technique.imageURL.isNotEmpty
                    ? technique.imageURL.first
                    : null,
              ),
            )
            .toList();
        return _sortedItems(items, query.sortBy);
      }

      if (query.categoryId == LibraryCategoryIds.nutrition) {
        final nutritions = await ref.watch(nutritionDetailsProvider.future);
        final filtered = nutritions.where((nutrition) {
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return nutrition.name.toLowerCase().contains(normalizedQuery);
        });

        final items = filtered
            .map(
              (nutrition) => LibraryCatalogItem(
                id: nutrition.id,
                name: nutrition.name,
                description: nutrition.description,
              ),
            )
            .toList();
        return _sortedItems(items, query.sortBy);
      }

      if (query.categoryId == LibraryCategoryIds.units) {
        final units = await ref.watch(unitsProvider.future);
        final filtered = units.where((unit) {
          final matchesSubCategory =
              unit.type.toLowerCase() == query.subCategoryId.toLowerCase();
          if (!matchesSubCategory) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return unit.name.toLowerCase().contains(normalizedQuery);
        });

        final items = filtered
            .map(
              (unit) => LibraryCatalogItem(
                id: unit.id,
                name: unit.name,
                description: unit.description?.trim().isNotEmpty == true
                    ? unit.description!.trim()
                    : 'Multiplier: ${unit.multiplier} (${unit.type})',
              ),
            )
            .toList();
        return _sortedItems(items, query.sortBy);
      }

      return const <LibraryCatalogItem>[];
    });
