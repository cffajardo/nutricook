import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all public recipes (for browse/discover)
  Stream<List<Recipe>> getPublicRecipes({int limit = 20}) {
    return _db
      .collection(FirestoreConstants.recipes)
      .where('isPublic', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList());
  }

  /// Get single recipe by ID
  Stream<Recipe?> getRecipeById(String recipeId) {
    return _db
      .collection(FirestoreConstants.recipes)
      .doc(recipeId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return Recipe.fromJson(doc.data()!);
      });
  }

  /// Get user's own recipes
  Stream<List<Recipe>> getUserRecipes(String userId) {
    return _db
      .collection(FirestoreConstants.recipes)
      .where('ownerId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList());
  }

  /// Get trending recipes (most favorited)
  Stream<List<Recipe>> getTrendingRecipes({int limit = 10}) {
    return _db
      .collection(FirestoreConstants.recipes)
      .where('isPublic', isEqualTo: true)
      .orderBy('favoriteCount', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList());
  }

  /// Create new recipe
  Future<String> createRecipe(Recipe recipe) async {
    // Generate ID if not provided
    final recipeRef = recipe.id.isEmpty
        ? _db.collection(FirestoreConstants.recipes).doc()
        : _db.collection(FirestoreConstants.recipes).doc(recipe.id);

    final recipeWithId = recipe.copyWith(
      id: recipeRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await recipeRef.set(recipeWithId.toJson());
    return recipeRef.id;
  }

  /// Update existing recipe
  Future<void> updateRecipe(Recipe recipe) async {
    final updatedRecipe = recipe.copyWith(
      updatedAt: DateTime.now(),
    );

    await _db
      .collection(FirestoreConstants.recipes)
      .doc(recipe.id)
      .update(updatedRecipe.toJson());
  }

  /// Delete recipe
  Future<void> deleteRecipe(String recipeId) async {
    await _db
      .collection(FirestoreConstants.recipes)
      .doc(recipeId)
      .delete();
  }

  /// Search recipes by tags and/or name
  Stream<List<Recipe>> searchRecipes({
    String? query,
    List<String> tags = const [],
  }) {
    var ref = _db
      .collection(FirestoreConstants.recipes)
      .where('isPublic', isEqualTo: true);

    // Filter by tags if provided
    if (tags.isNotEmpty) {
      ref = ref.where('tags', arrayContainsAny: tags);
    }

    return ref
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        var recipes = snapshot.docs
          .map((doc) => Recipe.fromJson(doc.data()))
          .toList();

        // Filter by name query (client-side)
        if (query != null && query.isNotEmpty) {
          recipes = recipes.where((recipe) =>
            recipe.name.toLowerCase().contains(query.toLowerCase())
          ).toList();
        }

        return recipes;
      });
  }

  Future<void> addFavorite(String recipeId, String userId) async {
  final recipeRef = _db.collection(FirestoreConstants.recipes).doc(recipeId);
  await recipeRef.update({
    'favoriteCount': FieldValue.increment(1),
    'favoritedBy': FieldValue.arrayUnion([userId]),
  });
}

Future<void> removeFavorite(String recipeId, String userId) async {
  final recipeRef = _db.collection(FirestoreConstants.recipes).doc(recipeId);
  await recipeRef.update({
    'favoriteCount': FieldValue.increment(-1),
    'favoritedBy': FieldValue.arrayRemove([userId]),
  });
}
}

//ingredient lookup


//recently viewed?

//get recipe media

//verify recipe for public listing (check for prohibited content, etc.)
