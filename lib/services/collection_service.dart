import 'auth_service.dart';
import '../models/collection/collection.dart';
import '../models/collection_item/collection_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<String> createCollection({
    required String name,
    required String description,
    String? thumbnailUrl,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final collectionRef = _db.collection('collections').doc();
    final collection = Collection(
      id: collectionRef.id,
      ownerId: user.uid,
      name: name,
      description: description,
      thumbnailUrl: thumbnailUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await collectionRef.set(collection.toJson());
    return collection.id;
  }

  Future<void> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    String? thumbnailUrl,
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

    final updates = <String, dynamic>{
      'updatedAt': DateTime.now(),
    };
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (thumbnailUrl != null) updates['thumbnailUrl'] = thumbnailUrl;

    await collectionRef.update(updates);
  }

  Future<void> deleteCollection(String collectionId) async {
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

    // Delete all items in the collection
    final itemsSnapshot = await collectionRef.collection('items').get();
    for (final doc in itemsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the collection
    await collectionRef.delete();
  }

  Stream<List<Collection>> getUserCollections() {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _db
        .collection('collections')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Collection.fromJson(doc.data()))
            .toList());
  }

  Stream<Collection> getCollectionById(String collectionId) {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _db
        .collection('collections')
        .doc(collectionId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            throw Exception('Collection not found');
          }
          final data = snapshot.data()!;
          if (data['ownerId'] != user.uid) {
            throw Exception('Unauthorized');
          }
          return Collection.fromJson(data);
        });
  }

  Stream<List<CollectionItem>> getCollectionItems(String collectionId) {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _db
        .collection('collections')
        .doc(collectionId)
        .collection('items')
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionItem.fromJson(doc.data()))
            .toList());
  }
}