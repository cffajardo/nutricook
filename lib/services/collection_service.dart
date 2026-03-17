import 'package:flutter/foundation.dart';
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
    bool isPublic = false,
    bool isDefault = false,
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
      isPublic: isPublic,
      isDefault: isDefault,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await collectionRef.set(collection.toJson());
    return collection.id;
  }

  Future<void> createDefaultFavoritesCollection(String userId) async {
    final collectionRef = _db.collection('collections').doc();
    final collection = Collection(
      id: collectionRef.id,
      ownerId: userId,
      name: 'Favorites',
      description: 'Your favorite recipes',
      isPublic: false,
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await collectionRef.set(collection.toJson());
  }

  Future<void> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    String? thumbnailUrl,
    bool? isPublic,
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

    final updates = <String, dynamic>{'updatedAt': DateTime.now()};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (thumbnailUrl != null) updates['thumbnailUrl'] = thumbnailUrl;
    if (isPublic != null) updates['isPublic'] = isPublic;

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

    if (data['isDefault'] == true) {
      throw Exception('The Favorites collection cannot be deleted');
    }

    final itemsSnapshot = await collectionRef.collection('items').get();
    for (final doc in itemsSnapshot.docs) {
      await doc.reference.delete();
    }

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
        .map(
          (snapshot) {
            final collections = snapshot.docs
                .map((doc) => Collection.fromJson(doc.data()))
                .where((col) => col.archived == false)
                .toList();
            
            collections.sort((a, b) {
              if (a.isDefault && !b.isDefault) return -1;
              if (!a.isDefault && b.isDefault) return 1;
              return b.createdAt.compareTo(a.createdAt);
            });
            
            return collections;
          },
        );
  }

  Stream<List<Collection>> getCollectionsByOwnerId(String ownerId) {
    return _db
        .collection('collections')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) {
            final collections = snapshot.docs
                .map((doc) => Collection.fromJson(doc.data()))
                .toList();
            
            collections.sort((a, b) {
              if (a.isDefault && !b.isDefault) return -1;
              if (!a.isDefault && b.isDefault) return 1;
              return b.createdAt.compareTo(a.createdAt);
            });
            
            return collections;
          },
        );
  }

  Stream<Collection> getCollectionById(String collectionId) {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _db.collection('collections').doc(collectionId).snapshots().map((
      snapshot,
    ) {
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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CollectionItem.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<Collection> getOrCreateFavoritesCollection() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final query = await _db
        .collection('collections')
        .where('ownerId', isEqualTo: user.uid)
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Collection.fromJson(query.docs.first.data());
    }

    final collectionRef = _db.collection('collections').doc();
    final favoritesCollection = Collection(
      id: collectionRef.id,
      ownerId: user.uid,
      name: 'Favorites',
      description: 'Your favorite recipes',
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await collectionRef.set(favoritesCollection.toJson());
    return favoritesCollection;
  }

  Future<void> addRecipeToFavorites({
    required String recipeId,
    required String recipeName,
    String? thumbnailUrl,
  }) async {
    try {
      final favoritesCollection = await getOrCreateFavoritesCollection();

      final existingItem = await _db
          .collection('collections')
          .doc(favoritesCollection.id)
          .collection('items')
          .where('recipeId', isEqualTo: recipeId)
          .limit(1)
          .get();

      if (existingItem.docs.isNotEmpty) {
        return; 
      }

      final itemRef = _db
          .collection('collections')
          .doc(favoritesCollection.id)
          .collection('items')
          .doc();

      final collectionItem = CollectionItem(
        id: itemRef.id,
        collectionId: favoritesCollection.id,
        recipeId: recipeId,
        recipeName: recipeName,
        thumbnailUrl: thumbnailUrl,
        tags: const [],
        prepTime: 0,
        cookTime: 0,
        addedAt: DateTime.now(),
        notes: null,
        order: 0,
      );

      await itemRef.set(collectionItem.toJson());

      await _db
          .collection('collections')
          .doc(favoritesCollection.id)
          .update({
        'recipeCount': FieldValue.increment(1),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      debugPrint('Error adding recipe to favorites: $e');
      rethrow;
    }
  }

  Future<void> removeRecipeFromFavorites(String recipeId) async {
    try {
      final favoritesCollection = await getOrCreateFavoritesCollection();

      final query = await _db
          .collection('collections')
          .doc(favoritesCollection.id)
          .collection('items')
          .where('recipeId', isEqualTo: recipeId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }

      if (query.docs.isNotEmpty) {
        await _db
            .collection('collections')
            .doc(favoritesCollection.id)
            .update({
          'recipeCount': FieldValue.increment(-query.docs.length),
          'updatedAt': DateTime.now(),
        });
      }
    } catch (e) {
      debugPrint('Error removing recipe from favorites: $e');
      rethrow;
    }
  }
}
