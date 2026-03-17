import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';

final archiveServiceProvider = Provider<ArchiveService>((ref) {
  return ArchiveService(ref);
});

class ArchiveService {
  ArchiveService(this._ref);
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Archives a document in the given collection by setting `archived = true`,
  /// `archivedAt`, and `deleteAfter` based on user preferences.
  Future<void> archiveItem({
    required String collection,
    required String docId,
  }) async {
    final prefs = await _ref.read(userPreferencesProvider.future);
    final retentionDays = prefs.archiveRetentionDays;
    
    final now = DateTime.now();
    DateTime? deleteAfter;
    if (retentionDays > 0) {
      deleteAfter = now.add(Duration(days: retentionDays));
    }

    await _firestore.collection(collection).doc(docId).update({
      'archived': true,
      'archivedAt': Timestamp.fromDate(now),
      'deleteAfter': deleteAfter != null ? Timestamp.fromDate(deleteAfter) : null,
    });
  }

  /// Restores an archived document by removing the archive metadata fields.
  Future<void> restoreItem({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).update({
      'archived': false,
      'archivedAt': FieldValue.delete(),
      'deleteAfter': FieldValue.delete(),
    });
  }

  /// Permanently deletes an item from the given collection.
  Future<void> permanentlyDeleteItem({
    required String collection,
    required String docId,
  }) async {
    // For collections that require complex soft-deletion or nested deletion
    // we should ideally route to their respective services. But for standard
    // docs we can delete them here.
    await _firestore.collection(collection).doc(docId).delete();
  }

  /// Runs the automatic cleanup of items past their retention date.
  /// Should be called on app startup.
  Future<void> runCleanup() async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null || userId.isEmpty) return;

    final now = Timestamp.now();
    final collectionsToClean = [
      AppConstants.collectionRecipes,
      AppConstants.collectionCollections,
      AppConstants.collectionIngredients,
    ];

    for (final collection in collectionsToClean) {
      try {
        final querySnapshot = await _firestore
            .collection(collection)
            .where('ownerId', isEqualTo: userId)
            .where('archived', isEqualTo: true)
            .where('deleteAfter', isLessThan: now)
            .get();

        for (final doc in querySnapshot.docs) {
          // Permanently delete expired items
          await doc.reference.delete();
        }
      } catch (e) {
        // Silently fail cleanup errors to not break app startup
        print('Error cleaning up archive in $collection: $e');
      }
    }
  }
}
