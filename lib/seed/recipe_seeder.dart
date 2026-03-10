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
        final data = _sanitizeForFirestore(_recipeToFirestoreData(recipe))
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
      'isVerified': recipe.isVerified,
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
        (key, entryValue) => MapEntry(
          key.toString(),
          _sanitizeForFirestore(entryValue),
        ),
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
        .expand((spec) => spec.ingredients.map((ingredient) => ingredient.ingredientID))
        .toSet();

    final existingSnapshot = await db.collection(FirestoreConstants.ingredients).get();
    final existingIds = existingSnapshot.docs.map((doc) => doc.id).toSet();
    final missingIds = requiredIngredientIds.difference(existingIds).toList()..sort();

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
        description: 'Auto-generated placeholder ingredient for recipe seeding.',
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
      _RecipeTemplate(
        baseName: 'Garlic Chicken Rice Bowl',
        description: 'Juicy chicken tossed with garlic and soy over warm rice.',
        servings: 2,
        prepTime: 15,
        cookTime: 18,
        tags: <String>['easy', 'american', 'high-protein'],
        techniqueIDs: <String>['chop', 'saute'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'chicken-breast', quantity: 260, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'white-rice', quantity: 1, unitID: 'cup'),
          RecipeIngredientDraft(ingredientID: 'onion', quantity: 60, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'garlic', quantity: 10, unitID: 'g', preparation: 'Minced'),
          RecipeIngredientDraft(ingredientID: 'soy-sauce', quantity: 1.5, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'olive-oil', quantity: 1, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'black-pepper', quantity: 0.25, unitID: 'tsp'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Season and slice the chicken into bite-size strips.', timerSeconds: 180),
          RecipeStepDraft(instruction: 'Saute onion and garlic in oil until fragrant.', timerSeconds: 240),
          RecipeStepDraft(instruction: 'Cook chicken until lightly browned, then add soy sauce.', timerSeconds: 420),
          RecipeStepDraft(instruction: 'Serve over cooked rice and finish with black pepper.', timerSeconds: 60),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Tofu Veggie Stir-Fry',
        description: 'Crisp vegetables and tofu in a light soy garlic glaze.',
        servings: 2,
        prepTime: 18,
        cookTime: 14,
        tags: <String>['easy', 'chinese', 'vegan', 'high-fiber'],
        techniqueIDs: <String>['chop', 'stir-fry'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'tofu', quantity: 250, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'broccoli', quantity: 140, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'bell-pepper', quantity: 120, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'carrot', quantity: 100, unitID: 'g', preparation: 'Sliced'),
          RecipeIngredientDraft(ingredientID: 'garlic', quantity: 8, unitID: 'g', preparation: 'Minced'),
          RecipeIngredientDraft(ingredientID: 'soy-sauce', quantity: 2, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'olive-oil', quantity: 1, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'brown-rice', quantity: 0.75, unitID: 'cup'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Press tofu and cut into cubes.', timerSeconds: 300),
          RecipeStepDraft(instruction: 'Stir-fry tofu until golden and set aside.', timerSeconds: 300),
          RecipeStepDraft(instruction: 'Cook vegetables with garlic, then add tofu and soy sauce.', timerSeconds: 420),
          RecipeStepDraft(instruction: 'Serve over warm brown rice.', timerSeconds: 60),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Tuna Tomato Pasta',
        description: 'Simple tuna pasta in a bright tomato and garlic sauce.',
        servings: 3,
        prepTime: 12,
        cookTime: 20,
        tags: <String>['easy', 'italian', 'high-protein'],
        techniqueIDs: <String>['boil', 'saute'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'spaghetti', quantity: 220, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'tuna', quantity: 180, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'tomato', quantity: 220, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'onion', quantity: 70, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'garlic', quantity: 8, unitID: 'g', preparation: 'Minced'),
          RecipeIngredientDraft(ingredientID: 'olive-oil', quantity: 1, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'salt', quantity: 0.5, unitID: 'tsp'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Boil spaghetti until al dente and reserve some pasta water.', timerSeconds: 600),
          RecipeStepDraft(instruction: 'Saute onion and garlic, then add tomatoes until softened.', timerSeconds: 360),
          RecipeStepDraft(instruction: 'Add tuna, toss in spaghetti, and loosen with pasta water.', timerSeconds: 240),
          RecipeStepDraft(instruction: 'Season and serve hot.', timerSeconds: 60),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Hearty Lentil Vegetable Soup',
        description: 'Comforting lentil soup packed with vegetables and flavor.',
        servings: 4,
        prepTime: 20,
        cookTime: 35,
        tags: <String>['medium', 'vegan', 'low-fat', 'high-fiber'],
        techniqueIDs: <String>['chop', 'simmer'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'lentils', quantity: 220, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'carrot', quantity: 120, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'onion', quantity: 80, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'tomato', quantity: 180, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'kale', quantity: 80, unitID: 'g', preparation: 'Chopped'),
          RecipeIngredientDraft(ingredientID: 'garlic', quantity: 10, unitID: 'g', preparation: 'Minced'),
          RecipeIngredientDraft(ingredientID: 'salt', quantity: 0.75, unitID: 'tsp'),
          RecipeIngredientDraft(ingredientID: 'black-pepper', quantity: 0.25, unitID: 'tsp'),
          RecipeIngredientDraft(ingredientID: 'water', quantity: 1200, unitID: 'ml'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Saute onion, carrot, and garlic until aromatic.', timerSeconds: 360),
          RecipeStepDraft(instruction: 'Add lentils, tomatoes, and water.', timerSeconds: 120),
          RecipeStepDraft(instruction: 'Simmer until lentils are tender.', timerSeconds: 1500),
          RecipeStepDraft(instruction: 'Stir in kale, season, and cook briefly.', timerSeconds: 180),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Shrimp Fried Rice',
        description: 'Savory fried rice with shrimp, egg, and crunchy vegetables.',
        servings: 3,
        prepTime: 14,
        cookTime: 15,
        tags: <String>['easy', 'chinese', 'high-protein'],
        techniqueIDs: <String>['stir-fry'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'shrimp', quantity: 220, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'white-rice', quantity: 2, unitID: 'cup'),
          RecipeIngredientDraft(ingredientID: 'egg', quantity: 2, unitID: 'piece'),
          RecipeIngredientDraft(ingredientID: 'carrot', quantity: 90, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'scallions', quantity: 25, unitID: 'g', preparation: 'Sliced'),
          RecipeIngredientDraft(ingredientID: 'soy-sauce', quantity: 2, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'olive-oil', quantity: 1, unitID: 'tbsp'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Scramble eggs and set aside.', timerSeconds: 180),
          RecipeStepDraft(instruction: 'Stir-fry shrimp until pink, then remove.', timerSeconds: 240),
          RecipeStepDraft(instruction: 'Cook carrot and rice, then add soy sauce.', timerSeconds: 360),
          RecipeStepDraft(instruction: 'Return shrimp and egg, toss with scallions.', timerSeconds: 180),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Beef and Broccoli Skillet',
        description: 'Tender beef and broccoli in a quick soy-garlic pan sauce.',
        servings: 2,
        prepTime: 16,
        cookTime: 14,
        tags: <String>['easy', 'chinese', 'low-carb', 'high-protein'],
        techniqueIDs: <String>['slice', 'stir-fry'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'beef-lean', quantity: 260, unitID: 'g', preparation: 'Sliced'),
          RecipeIngredientDraft(ingredientID: 'broccoli', quantity: 180, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'garlic', quantity: 10, unitID: 'g', preparation: 'Minced'),
          RecipeIngredientDraft(ingredientID: 'soy-sauce', quantity: 1.5, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'olive-oil', quantity: 1, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'black-pepper', quantity: 0.25, unitID: 'tsp'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Sear beef strips in a hot pan and remove.', timerSeconds: 300),
          RecipeStepDraft(instruction: 'Cook broccoli until bright and crisp-tender.', timerSeconds: 300),
          RecipeStepDraft(instruction: 'Add garlic, soy sauce, and return beef.', timerSeconds: 240),
          RecipeStepDraft(instruction: 'Finish with black pepper and serve.', timerSeconds: 60),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Lemon Salmon Quinoa Plate',
        description: 'Pan-seared salmon with quinoa and sauteed spinach.',
        servings: 2,
        prepTime: 14,
        cookTime: 20,
        tags: <String>['medium', 'american', 'high-protein'],
        techniqueIDs: <String>['sear', 'boil'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'salmon', quantity: 260, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'quinoa', quantity: 0.75, unitID: 'cup'),
          RecipeIngredientDraft(ingredientID: 'spinach', quantity: 90, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'lemon', quantity: 1, unitID: 'piece'),
          RecipeIngredientDraft(ingredientID: 'olive-oil', quantity: 1, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'salt', quantity: 0.5, unitID: 'tsp'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Cook quinoa until fluffy.', timerSeconds: 900),
          RecipeStepDraft(instruction: 'Season salmon and sear until just cooked.', timerSeconds: 420),
          RecipeStepDraft(instruction: 'Saute spinach quickly in olive oil.', timerSeconds: 120),
          RecipeStepDraft(instruction: 'Plate with lemon juice over salmon.', timerSeconds: 60),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Chickpea Avocado Salad',
        description: 'Fresh, creamy, and protein-rich salad with lemon dressing.',
        servings: 2,
        prepTime: 12,
        cookTime: 0,
        tags: <String>['easy', 'vegan', 'dairy-free', 'high-fiber'],
        techniqueIDs: <String>['mix'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'chickpeas-canned', quantity: 240, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'avocado', quantity: 150, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'cucumber', quantity: 140, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'tomato', quantity: 140, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'lemon', quantity: 1, unitID: 'piece'),
          RecipeIngredientDraft(ingredientID: 'olive-oil', quantity: 1, unitID: 'tbsp'),
          RecipeIngredientDraft(ingredientID: 'salt', quantity: 0.25, unitID: 'tsp'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Rinse chickpeas and drain well.', timerSeconds: 120),
          RecipeStepDraft(instruction: 'Dice avocado, cucumber, and tomato.', timerSeconds: 240),
          RecipeStepDraft(instruction: 'Toss all ingredients with lemon juice and olive oil.', timerSeconds: 120),
          RecipeStepDraft(instruction: 'Season to taste and serve chilled.', timerSeconds: 60),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Veggie Omelet',
        description: 'Fluffy omelet loaded with spinach, tomato, and onion.',
        servings: 1,
        prepTime: 8,
        cookTime: 8,
        tags: <String>['easy', 'low-carb', 'high-protein'],
        techniqueIDs: <String>['whisk', 'saute'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'egg', quantity: 3, unitID: 'piece'),
          RecipeIngredientDraft(ingredientID: 'spinach', quantity: 50, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'tomato', quantity: 70, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'onion', quantity: 40, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'olive-oil', quantity: 1, unitID: 'tsp'),
          RecipeIngredientDraft(ingredientID: 'black-pepper', quantity: 0.2, unitID: 'tsp'),
          RecipeIngredientDraft(ingredientID: 'salt', quantity: 0.2, unitID: 'tsp'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Whisk eggs with salt and pepper.', timerSeconds: 90),
          RecipeStepDraft(instruction: 'Saute onion, tomato, and spinach briefly.', timerSeconds: 150),
          RecipeStepDraft(instruction: 'Pour eggs and cook until set.', timerSeconds: 240),
          RecipeStepDraft(instruction: 'Fold and serve warm.', timerSeconds: 60),
        ],
      ),
      _RecipeTemplate(
        baseName: 'Pork and Vegetable Stew',
        description: 'Rich one-pot pork stew with potato, carrot, and tomato.',
        servings: 4,
        prepTime: 20,
        cookTime: 45,
        tags: <String>['medium', 'american', 'high-protein'],
        techniqueIDs: <String>['chop', 'stew'],
        ingredients: <RecipeIngredientDraft>[
          RecipeIngredientDraft(ingredientID: 'pork-loin', quantity: 420, unitID: 'g'),
          RecipeIngredientDraft(ingredientID: 'potato', quantity: 320, unitID: 'g', preparation: 'Cubed'),
          RecipeIngredientDraft(ingredientID: 'carrot', quantity: 180, unitID: 'g', preparation: 'Sliced'),
          RecipeIngredientDraft(ingredientID: 'onion', quantity: 110, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'tomato', quantity: 220, unitID: 'g', preparation: 'Diced'),
          RecipeIngredientDraft(ingredientID: 'garlic', quantity: 12, unitID: 'g', preparation: 'Minced'),
          RecipeIngredientDraft(ingredientID: 'salt', quantity: 1, unitID: 'tsp'),
          RecipeIngredientDraft(ingredientID: 'black-pepper', quantity: 0.5, unitID: 'tsp'),
          RecipeIngredientDraft(ingredientID: 'water', quantity: 900, unitID: 'ml'),
        ],
        steps: <RecipeStepDraft>[
          RecipeStepDraft(instruction: 'Brown pork with garlic and onion.', timerSeconds: 420),
          RecipeStepDraft(instruction: 'Add tomato and cook until softened.', timerSeconds: 240),
          RecipeStepDraft(instruction: 'Add potato, carrot, water, and simmer.', timerSeconds: 1800),
          RecipeStepDraft(instruction: 'Season and cook until pork is tender.', timerSeconds: 480),
        ],
      ),
    ];

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
          isVerified: true,
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
