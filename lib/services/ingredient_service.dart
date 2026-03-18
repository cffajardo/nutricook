import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/services/generative_ai_service.dart';

class IngredientService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Ingredient>> getAllIngredientsStream() {
    return _db
        .collection(FirestoreConstants.ingredients)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ingredient.fromJson(doc.data()..['id'] = doc.id))
            .where((ing) => ing.archived == false)
            .toList());
  }

  Future<List<Ingredient>> getAllIngredients() async {
    final snapshot = await _db
        .collection(FirestoreConstants.ingredients)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Ingredient.fromJson(doc.data()))
        .where((ing) => ing.archived == false)
        .toList();
  }

  Future<Ingredient?> getIngredientById(String ingredientId, {Source source = Source.serverAndCache}) async {
    final doc = await _db
        .collection(FirestoreConstants.ingredients)
        .doc(ingredientId)
        .get(GetOptions(source: source));

    if (!doc.exists) return null;
    return Ingredient.fromJson(doc.data()!);
  }

  Stream<List<Ingredient>> getUserCustomIngredients(String userId) {
    return _db
        .collection(FirestoreConstants.ingredients)
        .where('ownerId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ingredient.fromJson(doc.data()..['id'] = doc.id))
            .where((ing) => ing.archived == false)
            .toList());
  }

  Future<List<Ingredient>> getIngredientsByCategory(String category) async {
    final snapshot = await _db
        .collection(FirestoreConstants.ingredients)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Ingredient.fromJson(doc.data()))
        .where((ing) => ing.archived == false)
        .toList();
  }

  Future<String> createIngredient(Ingredient ingredient, {bool isTemporary = false, String? createdInRecipeId}) async {
    final ingredientRef = ingredient.id.isEmpty
        ? _db.collection(FirestoreConstants.ingredients).doc()
        : _db.collection(FirestoreConstants.ingredients).doc(ingredient.id);

    final userId = _auth.currentUser?.uid;

    final ingredientWithId = ingredient.copyWith(
      id: ingredientRef.id,
      ownerId: userId, 
    );

    debugPrint('🔍 INGREDIENT SERVICE DEBUG:');
    debugPrint('  Name: ${ingredientWithId.name}');
    debugPrint('  NutritionInfo object: ${ingredientWithId.nutritionPer100g}');
    final json = ingredientWithId.toJson();
    
    if (isTemporary) {
      json['isTemporary'] = true;
      if (createdInRecipeId != null) {
        json['createdInRecipeId'] = createdInRecipeId;
      }
    }

    debugPrint('  Serialized JSON with metadata: $json');
    debugPrint('  nutritionPer100g in JSON: ${json['nutritionPer100g']}');
    debugPrint('  nutritionPer100g type: ${json['nutritionPer100g'].runtimeType}');

    ingredientRef.set(json);
    return ingredientRef.id;
  }

  Future<void> promoteTemporaryIngredients(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _db
        .collection(FirestoreConstants.ingredients)
        .where('ownerId', isEqualTo: userId)
        .where('isTemporary', isEqualTo: true)
        .where('createdInRecipeId', isEqualTo: recipeId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isTemporary': false,
        'createdInRecipeId': FieldValue.delete(),
      });
    }
    batch.commit();
  }

  Future<void> cleanupTemporaryIngredients(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _db
        .collection(FirestoreConstants.ingredients)
        .where('ownerId', isEqualTo: userId)
        .where('isTemporary', isEqualTo: true)
        .where('createdInRecipeId', isEqualTo: recipeId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.commit();
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    final userId = _auth.currentUser?.uid;

    if (ingredient.ownerId != userId) {
      throw Exception('You can only update your own custom ingredients');
    }

    _db
        .collection(FirestoreConstants.ingredients)
        .doc(ingredient.id)
        .update(ingredient.toJson());
  }

  Future<void> deleteIngredient(String ingredientId) async {
    final userId = _auth.currentUser?.uid;

    final ingredient = await getIngredientById(ingredientId, source: Source.serverAndCache);

    if (ingredient == null) {
      throw Exception('Ingredient not found');
    }

    if (ingredient.ownerId != userId) {
      throw Exception('You can only delete your own custom ingredients');
    }

    _db
        .collection(FirestoreConstants.ingredients)
        .doc(ingredientId)
        .delete();
  }

  Future<List<Ingredient>> searchIngredients(String query) async {
    final allIngredients = await getAllIngredients();

    if (query.isEmpty) return allIngredients;

    return allIngredients
        .where((ing) => ing.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<bool> isIngredientNameTaken(String name) async {
    final snapshot = await _db
        .collection(FirestoreConstants.ingredients)
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> enrichMissingProperties(GenerativeAiService aiService) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _db
        .collection(FirestoreConstants.ingredients)
        .where('ownerId', isEqualTo: userId)
        .get();

    final ingredientsToEnrich = snapshot.docs
        .map((doc) => Ingredient.fromJson(doc.data()..['id'] = doc.id))
        .where((ing) => (ing.densityGPerMl == null || ing.densityGPerMl == 0) && (ing.avgWeightG == null || ing.avgWeightG == 0))
        .toList();

    if (ingredientsToEnrich.isEmpty) return;

    for (final ingredient in ingredientsToEnrich) {
      try {
        final analysis = await aiService.analyzePhysicalProperties(ingredient.name);
        
        final Map<String, dynamic> updates = {};
        if (analysis.category == 'LIQUID' && analysis.value != null) {
          updates['densityGPerMl'] = analysis.value;
        } else if (analysis.category == 'SOLID_PIECE' && analysis.value != null) {
          updates['avgWeightG'] = analysis.value;
        }
        
        updates['isAnalyzed'] = true;

        await _db
            .collection(FirestoreConstants.ingredients)
            .doc(ingredient.id)
            .update(updates);
        debugPrint('✅ Enriched ${ingredient.name}: ${analysis.category} (${analysis.value})');
      } catch (e) {
        debugPrint('❌ Failed to enrich ${ingredient.name}: $e');
      }
    }
  }
}