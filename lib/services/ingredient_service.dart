import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';

class IngredientService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Ingredient>> getAllIngredients() async {
    final snapshot = await _db
        .collection(FirestoreConstants.ingredients)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Ingredient.fromJson(doc.data()))
        .toList();
  }

  Future<Ingredient?> getIngredientById(String ingredientId) async {
    final doc = await _db
        .collection(FirestoreConstants.ingredients)
        .doc(ingredientId)
        .get();

    if (!doc.exists) return null;
    return Ingredient.fromJson(doc.data()!);
  }

  /// Get user's custom ingredients only
  Stream<List<Ingredient>> getUserCustomIngredients(String userId) {
    return _db
        .collection(FirestoreConstants.ingredients)
        .where('ownerId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ingredient.fromJson(doc.data()))
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
        .toList();
  }

  Future<String> createIngredient(Ingredient ingredient) async {
    final ingredientRef = ingredient.id.isEmpty
        ? _db.collection(FirestoreConstants.ingredients).doc()
        : _db.collection(FirestoreConstants.ingredients).doc(ingredient.id);

    final userId = _auth.currentUser?.uid;

    final ingredientWithId = ingredient.copyWith(
      id: ingredientRef.id,
      ownerId: userId, 
    );

    await ingredientRef.set(ingredientWithId.toJson());
    return ingredientRef.id;
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    final userId = _auth.currentUser?.uid;

    // Verify ownership
    if (ingredient.ownerId != userId) {
      throw Exception('You can only update your own custom ingredients');
    }

    await _db
        .collection(FirestoreConstants.ingredients)
        .doc(ingredient.id)
        .update(ingredient.toJson());
  }

  // For Custom Ingredients Only - Deletes the ingredient document
  Future<void> deleteIngredient(String ingredientId) async {
    final userId = _auth.currentUser?.uid;

    final ingredient = await getIngredientById(ingredientId);

    if (ingredient == null) {
      throw Exception('Ingredient not found');
    }

    if (ingredient.ownerId != userId) {
      throw Exception('You can only delete your own custom ingredients');
    }

    await _db
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
}