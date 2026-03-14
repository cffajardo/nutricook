import 'package:flutter/material.dart';
import 'package:nutricook/core/constants.dart';

class LibraryCategoryIds {
  static const ingredients = 'ingredients';
  static const techniques = 'techniques';
  static const nutrition = 'nutrition';
  static const units = 'units';
}

class LibrarySubCategoryIds {
  static const all = 'all';
  static const weight = 'weight';
  static const volume = 'volume';
  static const count = 'count';
  static const energy = 'energy';
  static const custom = 'custom';
}

@immutable
class LibraryCategoryDef {
  const LibraryCategoryDef({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

@immutable
class LibrarySubCategoryDef {
  const LibrarySubCategoryDef({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

const List<LibraryCategoryDef> kLibraryCategories = <LibraryCategoryDef>[
  LibraryCategoryDef(
    id: LibraryCategoryIds.ingredients,
    label: 'Ingredients',
    icon: Icons.egg_alt_outlined,
  ),
  LibraryCategoryDef(
    id: LibraryCategoryIds.techniques,
    label: 'Techniques',
    icon: Icons.outdoor_grill_outlined,
  ),
  LibraryCategoryDef(
    id: LibraryCategoryIds.nutrition,
    label: 'Nutrition',
    icon: Icons.bar_chart_outlined,
  ),
  LibraryCategoryDef(
    id: LibraryCategoryIds.units,
    label: 'Units',
    icon: Icons.straighten_rounded,
  ),
];

const Map<String, List<LibrarySubCategoryDef>> kLibrarySubCategoriesByCategory =
    <String, List<LibrarySubCategoryDef>>{
      LibraryCategoryIds.ingredients: <LibrarySubCategoryDef>[
        LibrarySubCategoryDef(
          id: IngredientCategory.proteins,
          label: IngredientCategory.proteins,
          icon: Icons.set_meal_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.vegetables,
          label: IngredientCategory.vegetables,
          icon: Icons.eco_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.fruits,
          label: IngredientCategory.fruits,
          icon: Icons.apple_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.dairy,
          label: IngredientCategory.dairy,
          icon: Icons.local_drink_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.grains,
          label: IngredientCategory.grains,
          icon: Icons.grain_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.spices,
          label: IngredientCategory.spices,
          icon: Icons.spa_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.herbs,
          label: IngredientCategory.herbs,
          icon: Icons.yard_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.sauces,
          label: IngredientCategory.sauces,
          icon: Icons.soup_kitchen_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.seafood,
          label: IngredientCategory.seafood,
          icon: Icons.phishing_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.nutsAndSeeds,
          label: IngredientCategory.nutsAndSeeds,
          icon: Icons.energy_savings_leaf_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.fatsAndOils,
          label: IngredientCategory.fatsAndOils,
          icon: Icons.water_drop_outlined,
        ),
        LibrarySubCategoryDef(
          id: IngredientCategory.beverages,
          label: IngredientCategory.beverages,
          icon: Icons.local_cafe_outlined,
        ),
        LibrarySubCategoryDef(
          id: LibrarySubCategoryIds.custom,
          label: 'Custom',
          icon: Icons.add_circle_outline_rounded,
        ),
      ],
      LibraryCategoryIds.techniques: <LibrarySubCategoryDef>[
        LibrarySubCategoryDef(
          id: TechniqueCategory.cutting,
          label: TechniqueCategory.cutting,
          icon: Icons.content_cut_outlined,
        ),
        LibrarySubCategoryDef(
          id: TechniqueCategory.prep,
          label: TechniqueCategory.prep,
          icon: Icons.kitchen_outlined,
        ),
        LibrarySubCategoryDef(
          id: TechniqueCategory.dryHeat,
          label: TechniqueCategory.dryHeat,
          icon: Icons.local_fire_department_outlined,
        ),
        LibrarySubCategoryDef(
          id: TechniqueCategory.moistHeat,
          label: TechniqueCategory.moistHeat,
          icon: Icons.waves_outlined,
        ),
        LibrarySubCategoryDef(
          id: TechniqueCategory.combination,
          label: TechniqueCategory.combination,
          icon: Icons.all_inclusive_outlined,
        ),
        LibrarySubCategoryDef(
          id: TechniqueCategory.presentation,
          label: TechniqueCategory.presentation,
          icon: Icons.restaurant_menu_outlined,
        ),
      ],
      LibraryCategoryIds.nutrition: <LibrarySubCategoryDef>[
        LibrarySubCategoryDef(
          id: LibrarySubCategoryIds.all,
          label: 'All Nutrients',
          icon: Icons.monitor_heart_outlined,
        ),
      ],
      LibraryCategoryIds.units: <LibrarySubCategoryDef>[
        LibrarySubCategoryDef(
          id: LibrarySubCategoryIds.weight,
          label: 'Weight',
          icon: Icons.scale_outlined,
        ),
        LibrarySubCategoryDef(
          id: LibrarySubCategoryIds.volume,
          label: 'Volume',
          icon: Icons.invert_colors_outlined,
        ),
        LibrarySubCategoryDef(
          id: LibrarySubCategoryIds.count,
          label: 'Count',
          icon: Icons.pin_outlined,
        ),
        LibrarySubCategoryDef(
          id: LibrarySubCategoryIds.energy,
          label: 'Energy',
          icon: Icons.bolt_outlined,
        ),
      ],
    };

LibraryCategoryDef? libraryCategoryById(String categoryId) {
  for (final category in kLibraryCategories) {
    if (category.id == categoryId) {
      return category;
    }
  }
  return null;
}

LibrarySubCategoryDef? librarySubCategoryById({
  required String categoryId,
  required String subCategoryId,
}) {
  final subCategories =
      kLibrarySubCategoriesByCategory[categoryId] ??
      const <LibrarySubCategoryDef>[];
  for (final subCategory in subCategories) {
    if (subCategory.id == subCategoryId) {
      return subCategory;
    }
  }
  return null;
}
