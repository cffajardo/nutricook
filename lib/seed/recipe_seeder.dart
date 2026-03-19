import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/seed/recipe_seed_helpers.dart';

class RecipeSeeder {
  static Future<void> seed(FirebaseFirestore db) async {
    final specs = _buildRecipeSpecs();
    await _deleteExistingSeedRecipes(db);
    await _ensureIngredientsExist(db, specs);
    final refData = await RecipeSeedHelpers.loadReferenceData(db);

    final batch = db.batch();
    for (final spec in specs) {
      final recipe = RecipeSeedHelpers.buildEnrichedRecipe(
        spec: spec,
        ingredientsMap: refData.ingredientsMap,
        unitsMap: refData.unitsMap,
        ownerId: 'seed_system',
      );
      final data =
          _sanitizeForFirestore(_recipeToFirestoreData(recipe))
              as Map<String, dynamic>;
      batch.set(db.collection(FirestoreConstants.recipes).doc(recipe.id), data);
    }
    await batch.commit();
  }

  static Future<void> _deleteExistingSeedRecipes(FirebaseFirestore db) async {
    final existing = await db
        .collection(FirestoreConstants.recipes)
        .where('ownerId', isEqualTo: 'seed_system')
        .get();

    if (existing.docs.isEmpty) {
      return;
    }

    final batch = db.batch();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static Map<String, dynamic> _recipeToFirestoreData(Recipe recipe) {
    return <String, dynamic>{
      'id': recipe.id,
      'name': recipe.name,
      'description': recipe.description,
      'isPublic': recipe.isPublic,
      'servings': recipe.servings,
      'cookTime': recipe.cookTime,
      'prepTime': recipe.prepTime,
      'createdAt': Timestamp.fromDate(recipe.createdAt),
      'updatedAt': Timestamp.fromDate(recipe.updatedAt),
      'ownerId': recipe.ownerId,
      'favoriteCount': recipe.favoriteCount,
      'reportCount': recipe.reportCount,
      'tags': recipe.tags,
      'techniqueIDs': recipe.techniqueIDs,
      'imageURL': recipe.imageURL,
      'ingredients': recipe.ingredients
          .map(
            (item) => <String, dynamic>{
              'ingredientID': item.ingredientID,
              'name': item.name,
              'quantity': item.quantity,
              'unitID': item.unitID,
              'unitName': item.unitName,
              'nutritionPer100g': item.nutritionPer100g?.toJson(),
              'densityGPerMl': item.densityGPerMl,
              'avgWeightG': item.avgWeightG,
              'calculatedWeightG': item.calculatedWeightG,
              'preparation': item.preparation,
            },
          )
          .toList(),
      'steps': recipe.steps
          .map(
            (item) => <String, dynamic>{
              'instruction': item.instruction,
              'timerSeconds': item.timerSeconds,
            },
          )
          .toList(),
      'nutritionTotal': recipe.nutritionTotal?.toJson(),
      'nutritionPerServing': recipe.nutritionPerServing?.toJson(),
    };
  }

  static dynamic _sanitizeForFirestore(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is Timestamp) {
      return value;
    }
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }
    if (value is NutritionInfo) {
      return value.toJson();
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) =>
            MapEntry(key.toString(), _sanitizeForFirestore(entryValue)),
      );
    }
    if (value is Iterable) {
      return value.map(_sanitizeForFirestore).toList();
    }
    return value;
  }

  static Future<void> _ensureIngredientsExist(
    FirebaseFirestore db,
    List<RecipeSeedSpec> specs,
  ) async {
    final requiredIngredientIds = specs
        .expand(
          (spec) =>
              spec.ingredients.map((ingredient) => ingredient.ingredientID),
        )
        .toSet();

    final existingSnapshot = await db
        .collection(FirestoreConstants.ingredients)
        .get();
    final existingIds = existingSnapshot.docs.map((doc) => doc.id).toSet();
    final missingIds = requiredIngredientIds.difference(existingIds).toList()
      ..sort();

    if (missingIds.isEmpty) {
      return;
    }

    final batch = db.batch();
    for (final id in missingIds) {
      final placeholder = Ingredient(
        id: id,
        ownerId: 'seed_system',
        name: _humanizeIngredientId(id),
        category: IngredientCategory.custom,
        description:
            'Auto-generated placeholder ingredient for recipe seeding.',
        nutritionPer100g: const NutritionInfo(
          calories: 0,
          carbohydrates: 0,
          protein: 0,
          fat: 0,
          fiber: 0,
          sugar: 0,
          sodium: 0,
        ),
      );
      final data = placeholder.toJson();
      data['nutritionPer100g'] = placeholder.nutritionPer100g!.toJson();
      batch.set(
        db.collection(FirestoreConstants.ingredients).doc(id),
        data,
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  static String _humanizeIngredientId(String id) {
    return id
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static List<RecipeSeedSpec> _buildRecipeSpecs() {
    final templates = <_RecipeTemplate>[
      

    final specs = <RecipeSeedSpec>[];
    for (var i = 0; i < templates.length; i++) {
      final template = templates[i];
      final recipeId = 'seed-recipe-${(i + 1).toString().padLeft(2, '0')}';

      specs.add(
        RecipeSeedSpec(
          id: recipeId,
          name: template.baseName,
          description: template.description,
          servings: template.servings,
          prepTime: template.prepTime,
          cookTime: template.cookTime,
          steps: template.steps,
          ingredients: template.ingredients,
          tags: template.tags,
          techniqueIDs: template.techniqueIDs,
          imageURL: const <String>[],
          isPublic: true,
        ),
      );
    }

    return specs;
  }
}

class _RecipeTemplate {
  final String baseName;
  final String description;
  final int servings;
  final int prepTime;
  final int cookTime;
  final List<String> tags;
  final List<String> techniqueIDs;
  final List<RecipeIngredientDraft> ingredients;
  final List<RecipeStepDraft> steps;

  const _RecipeTemplate({
    required this.baseName,
    required this.description,
    required this.servings,
    required this.prepTime,
    required this.cookTime,
    required this.tags,
    required this.techniqueIDs,
    required this.ingredients,
    required this.steps,
  });
}
