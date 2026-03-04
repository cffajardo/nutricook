import 'auth_service.dart';
import '../models/collection_item/collection_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String> addItemToCollection({
    required String collectionId,
    required String recipeId,
    required String recipeName,
    String? thumbnailUrl,
    List<String>? tags,
    int prepTime = 0,
    int cookTime = 0,
    String? notes,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final collectionRef = _db.collection('collections').doc(collectionId);
    final snapshot = await collectionRef.get();

    if (!snapshot.exists) {
      throw Exception('Collection not found');
    }

    final data = snapshot.data()!;
    if (data['ownerId'] != user.uid) {
      throw Exception('Unauthorized');
    }

    final itemRef = collectionRef.collection('items').doc();
    final item = CollectionItem(
      id: itemRef.id,
      collectionId: collectionId,
      recipeId: recipeId,
      recipeName: recipeName,
      thumbnailUrl: thumbnailUrl,
      tags: tags ?? [],
      prepTime: prepTime,
      cookTime: cookTime,
      addedAt: DateTime.now(),
      notes: notes,
    );

    await itemRef.set(item.toJson());
    await collectionRef.update({'recipeCount': FieldValue.increment(1)});
    return item.id;
  }

  Future<void> removeItemFromCollection({
    required String collectionId,
    required String itemId,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final collectionRef = _db.collection('collections').doc(collectionId);
    final snapshot = await collectionRef.get();

    if (!snapshot.exists) {
      throw Exception('Collection not found');
    }

    final data = snapshot.data()!;
    if (data['ownerId'] != user.uid) {
      throw Exception('Unauthorized');
    }

    final itemRef = collectionRef.collection('items').doc(itemId);
    await itemRef.delete();
    await collectionRef.update({'recipeCount': FieldValue.increment(-1)});
  }

  Future<void> updateCollectionItem({
    required String collectionId,
    required String itemId,
    String? notes,
    List<String>? tags,
    double? order,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final collectionRef = _db.collection('collections').doc(collectionId);
    final snapshot = await collectionRef.get();

    if (!snapshot.exists) {
      throw Exception('Collection not found');
    }

    final data = snapshot.data()!;
    if (data['ownerId'] != user.uid) {
      throw Exception('Unauthorized');
    }

    final itemRef = collectionRef.collection('items').doc(itemId);
    final updates = <String, dynamic>{};
    if (notes != null) updates['notes'] = notes;
    if (tags != null) updates['tags'] = tags;
    if (order != null) updates['order'] = order;
    await itemRef.update(updates);
  }

  Future<List<CollectionItem>> getCollectionItems(String collectionId) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final collectionRef = _db.collection('collections').doc(collectionId);
    final snapshot = await collectionRef.get();

    if (!snapshot.exists) {
      throw Exception('Collection not found');
    }

    final data = snapshot.data()!;
    if (data['ownerId'] != user.uid) {
      throw Exception('Unauthorized');
    }

    final itemsSnapshot = await collectionRef.collection('items').get();
    return itemsSnapshot.docs
        .map((doc) => CollectionItem.fromJson(doc.data()))
        .toList();
  }
}