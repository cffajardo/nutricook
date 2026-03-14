import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/collection_item/collection_item.dart';
import 'package:nutricook/services/collection_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';

final collectionProvider = Provider<CollectionService>((ref) {
  return CollectionService();
});

final userCollectionsProvider = StreamProvider<List<Collection>>((ref) {
  final collectionService = ref.watch(collectionProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return collectionService.getUserCollections().map((collections) {
    // Sort so that default (favorites) collection comes first
    final sorted = [...collections];
    sorted.sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return 0;
    });
    return sorted;
  });
});

final userCollectionsByOwnerProvider =
    StreamProvider.family<List<Collection>, String>((ref, ownerId) {
      final collectionService = ref.watch(collectionProvider);
      return collectionService.getCollectionsByOwnerId(ownerId);
    });

final collectionDataProvider = StreamProvider.family<Collection, String>((
  ref,
  collectionId,
) {
  final collectionService = ref.watch(collectionProvider);
  return collectionService.getCollectionById(collectionId);
});

final collectionItemsProvider =
    StreamProvider.family<List<CollectionItem>, String>((ref, collectionId) {
      final collectionService = ref.watch(collectionProvider);
      return collectionService.getCollectionItems(collectionId);
    });
