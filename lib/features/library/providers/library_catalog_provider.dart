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

class LibraryItemDetailQuery {
  const LibraryItemDetailQuery({
    required this.categoryId,
    required this.itemId,
  });

  final String categoryId;
  final String itemId;

  @override
  bool operator ==(Object other) {
    return other is LibraryItemDetailQuery &&
        other.categoryId == categoryId &&
        other.itemId == itemId;
  }

  @override
  int get hashCode => Object.hash(categoryId, itemId);
}

class LibraryItemDetailField {
  const LibraryItemDetailField({required this.label, required this.value});

  final String label;
  final String value;
}

class LibraryItemDetailData {
  const LibraryItemDetailData({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.fields = const <LibraryItemDetailField>[],
  });

  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<LibraryItemDetailField> fields;
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
          // Handle custom category - show only user-created ingredients
          if (query.subCategoryId == LibrarySubCategoryIds.custom) {
            final isCustom = ingredient.ownerId != null && ingredient.ownerId!.isNotEmpty;
            if (!isCustom) {
              return false;
            }
          } else {
            // For other categories, filter by category
            final matchesSubCategory = ingredient.category == query.subCategoryId;
            if (!matchesSubCategory) {
              return false;
            }
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

final libraryItemDetailProvider =
    FutureProvider.family<LibraryItemDetailData?, LibraryItemDetailQuery>((
      ref,
      query,
    ) async {
      if (query.categoryId == LibraryCategoryIds.ingredients) {
        final ingredients = await ref.watch(ingredientsProvider.future);
        for (final ingredient in ingredients) {
          if (ingredient.id != query.itemId) continue;

          final nutrition = ingredient.nutritionPer100g;
          final fields = <LibraryItemDetailField>[
            LibraryItemDetailField(
              label: 'Category (per 100g)',
              value: ingredient.category,
            ),
            if (ingredient.densityGPerMl != null)
              LibraryItemDetailField(
                label: 'Density',
                value: '${ingredient.densityGPerMl!.toStringAsFixed(2)} g/ml',
              ),
            if (ingredient.avgWeightG != null)
              LibraryItemDetailField(
                label: 'Average Weight',
                value: '${ingredient.avgWeightG!.toStringAsFixed(2)} g',
              ),
            if (nutrition != null)
              LibraryItemDetailField(
                label: 'Calories',
                value: '${nutrition.calories} kcal',
              ),
            if (nutrition != null)
              LibraryItemDetailField(
                label: 'Carbohydrates',
                value: '${nutrition.carbohydrates.toStringAsFixed(2)} g',
              ),
            if (nutrition != null)
              LibraryItemDetailField(
                label: 'Protein',
                value: '${nutrition.protein.toStringAsFixed(2)} g',
              ),
            if (nutrition != null)
              LibraryItemDetailField(
                label: 'Fat',
                value: '${nutrition.fat.toStringAsFixed(2)} g',
              ),
            if (nutrition != null)
              LibraryItemDetailField(
                label: 'Fiber',
                value: '${nutrition.fiber.toStringAsFixed(2)} g',
              ),
            if (nutrition != null)
              LibraryItemDetailField(
                label: 'Sugar',
                value: '${nutrition.sugar.toStringAsFixed(2)} g',
              ),
            if (nutrition != null)
              LibraryItemDetailField(
                label: 'Sodium',
                value: '${(nutrition.sodium / 1000).toStringAsFixed(2)} g',
              ),
          ];

          return LibraryItemDetailData(
            id: ingredient.id,
            name: ingredient.name,
            description: ingredient.description?.trim().isNotEmpty == true
                ? ingredient.description!.trim()
                : 'No description available.',
            imageUrl: ingredient.imageURL,
            fields: fields,
          );
        }
      }

      if (query.categoryId == LibraryCategoryIds.techniques) {
        final techniques = await ref.watch(techniquesProvider.future);
        for (final technique in techniques) {
          if (technique.id != query.itemId) continue;

          return LibraryItemDetailData(
            id: technique.id,
            name: technique.name,
            description: technique.description?.trim().isNotEmpty == true
                ? technique.description!.trim()
                : 'No description available.',
            imageUrl: technique.imageURL.isNotEmpty
                ? technique.imageURL.first
                : null,
            fields: <LibraryItemDetailField>[
              LibraryItemDetailField(
                label: 'Category',
                value: technique.category,
              ),
            ],
          );
        }
      }

      if (query.categoryId == LibraryCategoryIds.nutrition) {
        final nutritions = await ref.watch(nutritionDetailsProvider.future);
        for (final nutrition in nutritions) {
          if (nutrition.id != query.itemId) continue;

          return LibraryItemDetailData(
            id: nutrition.id,
            name: nutrition.name,
            description: nutrition.description,
            fields: <LibraryItemDetailField>[
              LibraryItemDetailField(
                label: 'Recommended Daily Value',
                value: '${nutrition.recommendedDailyValue.toStringAsFixed(2)}',
              ),
            ],
          );
        }
      }

      if (query.categoryId == LibraryCategoryIds.units) {
        final units = await ref.watch(unitsProvider.future);
        for (final unit in units) {
          if (unit.id != query.itemId) continue;

          return LibraryItemDetailData(
            id: unit.id,
            name: unit.name,
            description: unit.description?.trim().isNotEmpty == true
                ? unit.description!.trim()
                : 'No description available.',
            fields: <LibraryItemDetailField>[
              LibraryItemDetailField(label: 'Type', value: unit.type),
            ],
          );
        }
      }

      return null;
    });
