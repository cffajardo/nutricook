import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/nutrition/nutrition.dart';
import 'package:nutricook/seed/ingredient_seeder.dart';
import 'package:nutricook/seed/recipe_seeder.dart';
import 'package:nutricook/seed/taxonomy_seeder.dart';
import 'package:nutricook/seed/technique_seeder.dart';
import 'package:nutricook/models/unit/unit.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seeds all reference collections
  static Future<void> seed() async {
    await _seedUnits();
    await _seedNutrition();
    await _seedIngredients();
    await _seedTechniques();
    await TaxonomySeeder.seed(_db);
    await _seedRecipes();
  }

  static Future<void> _seedUnits() async {
    final units = [
      const Unit(
        id: 'g',
        name: 'Gram',
        description: 'Metric unit of mass',
        multiplier: 1,
        type: 'weight',
      ),
      const Unit(
        id: 'kg',
        name: 'Kilogram',
        description: '1000 grams',
        multiplier: 1000,
        type: 'weight',
      ),
      const Unit(
        id: 'mg',
        name: 'Milligram',
        description: '0.001 grams',
        multiplier: 0.001,
        type: 'weight',
      ),
      const Unit(
        id: 'oz',
        name: 'Ounce',
        description: '~28.35 grams',
        multiplier: 28.3495,
        type: 'weight',
      ),
      const Unit(
        id: 'lb',
        name: 'Pound',
        description: '~453.6 grams',
        multiplier: 453.592,
        type: 'weight',
      ),
      const Unit(
        id: 'ml',
        name: 'Milliliter',
        description: 'Metric unit of volume',
        multiplier: 1,
        type: 'volume',
      ),
      const Unit(
        id: 'L',
        name: 'Liter',
        description: '1000 milliliters',
        multiplier: 1000,
        type: 'volume',
      ),
      const Unit(
        id: 'tsp',
        name: 'Teaspoon',
        description: '~5 ml',
        multiplier: 5,
        type: 'volume',
      ),
      const Unit(
        id: 'tbsp',
        name: 'Tablespoon',
        description: '~15 ml',
        multiplier: 15,
        type: 'volume',
      ),
      const Unit(
        id: 'cup',
        name: 'Cup',
        description: '~240 ml',
        multiplier: 240,
        type: 'volume',
      ),
      const Unit(
        id: 'kcal',
        name: 'Kilocalorie',
        description: 'Unit of energy (calories)',
        multiplier: 1,
        type: 'energy',
      ),
      const Unit(
        id: 'piece',
        name: 'Piece',
        description: 'Count/whole item',
        multiplier: 1,
        type: 'count',
      ),
      const Unit(
        id: 'clove',
        name: 'Clove',
        description: 'e.g. garlic clove',
        multiplier: 1,
        type: 'count',
      ),
      const Unit(
        id: 'slice',
        name: 'Slice',
        description: 'A single slice',
        multiplier: 1,
        type: 'count',
      ),
    ];

    final batch = _db.batch();
    for (final u in units) {
      batch.set(_db.collection(FirestoreConstants.units).doc(u.id), u.toJson());
    }
    await batch.commit();
  }

  static Future<void> _seedNutrition() async {
    final nutrition = [
      const Nutrition(
        id: 'calories',
        unitId: 'kcal',
        name: 'Calories',
        description: 'Energy from food',
        recommendedDailyValue: 2000,
      ),
      const Nutrition(
        id: 'protein',
        unitId: 'g',
        name: 'Protein',
        description: 'Essential for muscle and tissue',
        recommendedDailyValue: 50,
      ),
      const Nutrition(
        id: 'carbohydrates',
        unitId: 'g',
        name: 'Carbohydrates',
        description: 'Primary energy source',
        recommendedDailyValue: 300,
      ),
      const Nutrition(
        id: 'fat',
        unitId: 'g',
        name: 'Fat',
        description: 'Essential fatty acids and energy',
        recommendedDailyValue: 65,
      ),
      const Nutrition(
        id: 'fiber',
        unitId: 'g',
        name: 'Fiber',
        description: 'Supports digestion',
        recommendedDailyValue: 25,
      ),
      const Nutrition(
        id: 'sugar',
        unitId: 'g',
        name: 'Sugar',
        description: 'Simple carbohydrates',
        recommendedDailyValue: 50,
      ),
      const Nutrition(
        id: 'sodium',
        unitId: 'mg',
        name: 'Sodium',
        description: 'Important electrolyte',
        recommendedDailyValue: 2300,
      ),
    ];

    final batch = _db.batch();
    for (final n in nutrition) {
      batch.set(
        _db.collection(FirestoreConstants.nutrition).doc(n.id),
        n.toJson(),
      );
    }
    await batch.commit();
  }

  static Future<void> _seedIngredients() async {
    await IngredientSeeder.seed(_db, FirestoreConstants.ingredients);
  }

  static Future<void> _seedTechniques() async {
    await TechniqueSeeder.seed(_db, FirestoreConstants.techniques);
  }

  static Future<void> _seedRecipes() async {
    await RecipeSeeder.seed(_db);
  }
}
