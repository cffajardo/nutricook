import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/nutrition/nutrition.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/techniques/techniques.dart';
import 'package:nutricook/models/unit/unit.dart';


class DatabaseSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seeds all reference collections
  static Future<void> seed() async {
    await _seedUnits();
    await _seedNutrition();
    await _seedIngredients();
    await _seedTechniques();
  }

  static Future<void> _seedUnits() async {
    final units = [
      const Unit(id: 'g', name: 'Gram', description: 'Metric unit of mass', multiplier: 1, type: 'weight'),
      const Unit(id: 'kg', name: 'Kilogram', description: '1000 grams', multiplier: 1000, type: 'weight'),
      const Unit(id: 'mg', name: 'Milligram', description: '0.001 grams', multiplier: 0.001, type: 'weight'),
      const Unit(id: 'oz', name: 'Ounce', description: '~28.35 grams', multiplier: 28.3495, type: 'weight'),
      const Unit(id: 'lb', name: 'Pound', description: '~453.6 grams', multiplier: 453.592, type: 'weight'),
      const Unit(id: 'ml', name: 'Milliliter', description: 'Metric unit of volume', multiplier: 1, type: 'volume'),
      const Unit(id: 'L', name: 'Liter', description: '1000 milliliters', multiplier: 1000, type: 'volume'),
      const Unit(id: 'tsp', name: 'Teaspoon', description: '~5 ml', multiplier: 5, type: 'volume'),
      const Unit(id: 'tbsp', name: 'Tablespoon', description: '~15 ml', multiplier: 15, type: 'volume'),
      const Unit(id: 'cup', name: 'Cup', description: '~240 ml', multiplier: 240, type: 'volume'),
      const Unit(id: 'kcal', name: 'Kilocalorie', description: 'Unit of energy (calories)', multiplier: 1, type: 'energy'),
      const Unit(id: 'piece', name: 'Piece', description: 'Count/whole item', multiplier: 1, type: 'count'),
      const Unit(id: 'clove', name: 'Clove', description: 'e.g. garlic clove', multiplier: 1, type: 'count'),
      const Unit(id: 'slice', name: 'Slice', description: 'A single slice', multiplier: 1, type: 'count'),
    ];

    final batch = _db.batch();
    for (final u in units) {
      batch.set(_db.collection(FirestoreConstants.units).doc(u.id), u.toJson());
    }
    await batch.commit();
  }

  static Future<void> _seedNutrition() async {
    final nutrition = [
      const Nutrition(id: 'calories', unitId: 'kcal', name: 'Calories', description: 'Energy from food', recommendedDailyValue: 2000),
      const Nutrition(id: 'protein', unitId: 'g', name: 'Protein', description: 'Essential for muscle and tissue', recommendedDailyValue: 50),
      const Nutrition(id: 'carbohydrates', unitId: 'g', name: 'Carbohydrates', description: 'Primary energy source', recommendedDailyValue: 300),
      const Nutrition(id: 'fat', unitId: 'g', name: 'Fat', description: 'Essential fatty acids and energy', recommendedDailyValue: 65),
      const Nutrition(id: 'fiber', unitId: 'g', name: 'Fiber', description: 'Supports digestion', recommendedDailyValue: 25),
      const Nutrition(id: 'sugar', unitId: 'g', name: 'Sugar', description: 'Simple carbohydrates', recommendedDailyValue: 50),
      const Nutrition(id: 'sodium', unitId: 'mg', name: 'Sodium', description: 'Important electrolyte', recommendedDailyValue: 2300),
    ];

    final batch = _db.batch();
    for (final n in nutrition) {
      batch.set(_db.collection(FirestoreConstants.nutrition).doc(n.id), n.toJson());
    }
    await batch.commit();
  }

  static Future<void> _seedIngredients() async {
    final ingredients = [
      Ingredient(
        id: 'tomato',
        name: 'Tomato',
        category: IngredientCategory.vegetables,
        description: 'Ripe red tomato',
        nutritionPer100g: const NutritionInfo(calories: 18, carbohydrates: 3.9, protein: 0.9, fat: 0.2, fiber: 1.2, sugar: 2.6, sodium: 5),
        avgWeightG: 120,
      ),
      Ingredient(
        id: 'onion',
        name: 'Onion',
        category: IngredientCategory.vegetables,
        description: 'Yellow or white onion',
        nutritionPer100g: const NutritionInfo(calories: 40, carbohydrates: 9.3, protein: 1.1, fat: 0.1, fiber: 1.7, sugar: 4.2, sodium: 4),
        avgWeightG: 110,
      ),
      Ingredient(
        id: 'garlic',
        name: 'Garlic',
        category: IngredientCategory.vegetables,
        description: 'Fresh garlic bulb',
        nutritionPer100g: const NutritionInfo(calories: 149, carbohydrates: 33, protein: 6.4, fat: 0.5, fiber: 2.1, sugar: 1, sodium: 17),
      ),
      Ingredient(
        id: 'olive-oil',
        name: 'Olive Oil',
        category: IngredientCategory.fatsAndOils,
        description: 'Extra virgin olive oil',
        nutritionPer100g: const NutritionInfo(calories: 884, carbohydrates: 0, protein: 0, fat: 100, fiber: 0, sugar: 0, sodium: 2),
        densityGPerMl: 0.92,
      ),
      Ingredient(
        id: 'chicken-breast',
        name: 'Chicken Breast',
        category: IngredientCategory.proteins,
        description: 'Skinless, boneless chicken breast',
        nutritionPer100g: const NutritionInfo(calories: 165, carbohydrates: 0, protein: 31, fat: 3.6, fiber: 0, sugar: 0, sodium: 74),
      ),
      Ingredient(
        id: 'rice',
        name: 'White Rice',
        category: IngredientCategory.grains,
        description: 'Long-grain white rice, uncooked',
        nutritionPer100g: const NutritionInfo(calories: 365, carbohydrates: 80, protein: 7.1, fat: 0.7, fiber: 1.3, sugar: 0, sodium: 5),
      ),
      Ingredient(
        id: 'egg',
        name: 'Egg',
        category: IngredientCategory.proteins,
        description: 'Large whole egg',
        nutritionPer100g: const NutritionInfo(calories: 155, carbohydrates: 1.1, protein: 13, fat: 11, fiber: 0, sugar: 1.1, sodium: 124),
        avgWeightG: 50,
      ),
      Ingredient(
        id: 'milk',
        name: 'Whole Milk',
        category: IngredientCategory.dairy,
        description: 'Whole cow\'s milk',
        nutritionPer100g: const NutritionInfo(calories: 61, carbohydrates: 4.8, protein: 3.2, fat: 3.3, fiber: 0, sugar: 4.8, sodium: 43),
        densityGPerMl: 1.03,
      ),
      Ingredient(
        id: 'flour',
        name: 'All-Purpose Flour',
        category: IngredientCategory.grains,
        description: 'White wheat flour',
        nutritionPer100g: const NutritionInfo(calories: 364, carbohydrates: 76, protein: 10.3, fat: 1, fiber: 2.7, sugar: 0.3, sodium: 2),
      ),
      Ingredient(
        id: 'butter',
        name: 'Butter',
        category: IngredientCategory.dairy,
        description: 'Salted butter',
        nutritionPer100g: const NutritionInfo(calories: 717, carbohydrates: 0.1, protein: 0.9, fat: 81, fiber: 0, sugar: 0.1, sodium: 717),
        densityGPerMl: 0.91,
      ),
      Ingredient(
        id: 'lemon',
        name: 'Lemon',
        category: IngredientCategory.fruits,
        description: 'Fresh lemon',
        nutritionPer100g: const NutritionInfo(calories: 29, carbohydrates: 9.3, protein: 1.1, fat: 0.3, fiber: 2.8, sugar: 2.5, sodium: 2),
        avgWeightG: 58,
      ),
      Ingredient(
        id: 'carrot',
        name: 'Carrot',
        category: IngredientCategory.vegetables,
        description: 'Fresh orange carrot',
        nutritionPer100g: const NutritionInfo(calories: 41, carbohydrates: 9.6, protein: 0.9, fat: 0.2, fiber: 2.8, sugar: 4.7, sodium: 69),
        avgWeightG: 61,
      ),
      Ingredient(
        id: 'potato',
        name: 'Potato',
        category: IngredientCategory.vegetables,
        description: 'Russet or white potato',
        nutritionPer100g: const NutritionInfo(calories: 77, carbohydrates: 17.5, protein: 2, fat: 0.1, fiber: 2.2, sugar: 0.8, sodium: 6),
        avgWeightG: 170,
      ),
      Ingredient(
        id: 'salt',
        name: 'Table Salt',
        category: IngredientCategory.spices,
        description: 'Iodized table salt',
        nutritionPer100g: const NutritionInfo(calories: 0, carbohydrates: 0, protein: 0, fat: 0, fiber: 0, sugar: 0, sodium: 38758),
      ),
      Ingredient(
        id: 'black-pepper',
        name: 'Black Pepper',
        category: IngredientCategory.spices,
        description: 'Ground black pepper',
        nutritionPer100g: const NutritionInfo(calories: 251, carbohydrates: 64, protein: 10.4, fat: 3.3, fiber: 25.3, sugar: 0.6, sodium: 20),
      ),
    ];

    final batch = _db.batch();
    for (final i in ingredients) {
      batch.set(_db.collection(FirestoreConstants.ingredients).doc(i.id), i.toJson());
    }
    await batch.commit();
  }

  static Future<void> _seedTechniques() async {
    final techniques = [
      const Technique(id: 'chop', name: 'Chop', category: TechniqueCategory.cutting, description: 'Cut into rough pieces of similar size'),
      const Technique(id: 'dice', name: 'Dice', category: TechniqueCategory.cutting, description: 'Cut into small cubes, typically ¼ inch'),
      const Technique(id: 'mince', name: 'Mince', category: TechniqueCategory.cutting, description: 'Cut into very fine pieces'),
      const Technique(id: 'slice', name: 'Slice', category: TechniqueCategory.cutting, description: 'Cut into flat, thin pieces'),
      const Technique(id: 'julienne', name: 'Julienne', category: TechniqueCategory.cutting, description: 'Cut into thin matchstick strips'),
      const Technique(id: 'grate', name: 'Grate', category: TechniqueCategory.cutting, description: 'Reduce to small pieces using a grater'),
      const Technique(id: 'saute', name: 'Sauté', category: TechniqueCategory.dryHeat, description: 'Cook quickly in a little fat over high heat'),
      const Technique(id: 'fry', name: 'Fry', category: TechniqueCategory.dryHeat, description: 'Cook in hot oil'),
      const Technique(id: 'boil', name: 'Boil', category: TechniqueCategory.moistHeat, description: 'Cook in boiling liquid (212°F/100°C)'),
      const Technique(id: 'simmer', name: 'Simmer', category: TechniqueCategory.moistHeat, description: 'Cook in liquid just below boiling'),
      const Technique(id: 'bake', name: 'Bake', category: TechniqueCategory.dryHeat, description: 'Cook in dry heat in an oven'),
      const Technique(id: 'roast', name: 'Roast', category: TechniqueCategory.dryHeat, description: 'Cook with dry heat, typically at high temperature'),
      const Technique(id: 'grill', name: 'Grill', category: TechniqueCategory.dryHeat, description: 'Cook over direct heat on a grill'),
      const Technique(id: 'steam', name: 'Steam', category: TechniqueCategory.moistHeat, description: 'Cook with steam from boiling water'),
      const Technique(id: 'blanch', name: 'Blanch', category: TechniqueCategory.moistHeat, description: 'Briefly boil then shock in ice water'),
      const Technique(id: 'blend', name: 'Blend', category: TechniqueCategory.prep, description: 'Combine ingredients until smooth'),
      const Technique(id: 'whisk', name: 'Whisk', category: TechniqueCategory.prep, description: 'Beat vigorously to incorporate air'),
      const Technique(id: 'fold', name: 'Fold', category: TechniqueCategory.prep, description: 'Gently combine ingredients without deflating'),
      const Technique(id: 'knead', name: 'Knead', category: TechniqueCategory.prep, description: 'Work dough to develop gluten'),
      const Technique(id: 'braising', name: 'Braising', category: TechniqueCategory.combination, description: 'Cook in a closed container with liquid'),
      const Technique(id: 'stewing', name: 'Stewing', category: TechniqueCategory.combination, description: 'Cook in a liquid until tender'),
      const Technique(id: 'sous-vide', name: 'Sous Vide', category: TechniqueCategory.moistHeat, description: 'Cooking food in a sealed bag in a water bath, often followed by a dry-heat sear.'),
    ];

    final batch = _db.batch();
    for (final t in techniques) {
      batch.set(_db.collection(FirestoreConstants.techniques).doc(t.id), t.toJson());
    }
    await batch.commit();
  }
}
