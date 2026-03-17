import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';

final archivedRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection(FirestoreConstants.recipes)
      .where('ownerId', isEqualTo: userId)
      .where('archived', isEqualTo: true)
      .orderBy('archivedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});

final archivedCollectionsProvider = StreamProvider<List<Collection>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection(FirestoreConstants.collections)
      .where('ownerId', isEqualTo: userId)
      .where('archived', isEqualTo: true)
      .orderBy('archivedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Collection.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});

final archivedIngredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection(FirestoreConstants.ingredients)
      .where('ownerId', isEqualTo: userId)
      .where('archived', isEqualTo: true)
      .orderBy('archivedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});
