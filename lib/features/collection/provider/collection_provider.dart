import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/collection_item/collection_item.dart';
import 'package:nutricook/features/collection/provider/collection_notifier.dart';
import 'package:nutricook/services/collection_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final collectionProvider = Provider<CollectionService>((ref) {
  return CollectionService();
});

final userCollectionsProvider = StreamProvider<List<Collection>>((ref) {
  final collectionService = ref.watch(collectionProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value([]);
  }

  return collectionService.getUserCollections();
});

final collectionDataProvider = StreamProvider.family<Collection, String>((ref, collectionId) {
  final collectionService = ref.watch(collectionProvider);
  return collectionService.getCollectionById(collectionId);
});

final collectionItemsProvider = StreamProvider.family<List<CollectionItem>, String>((ref, collectionId) {
  final collectionService = ref.watch(collectionProvider);
  return collectionService.getCollectionItems(collectionId);
});

final selectedCollectionIdProvider =
    NotifierProvider<SelectedCollectionIdNotifier, String?>(
  SelectedCollectionIdNotifier.new,
);

final collectionSortProvider =
    NotifierProvider<CollectionSortNotifier, String>(
  CollectionSortNotifier.new,
);


