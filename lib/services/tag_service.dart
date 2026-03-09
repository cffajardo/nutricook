import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';

class TagService {
  TagService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _tags =>
      _db.collection(FirestoreConstants.tags);

  Stream<List<Map<String, dynamic>>> getAllTags() {
    return _tags.where('isActive', isEqualTo: true).snapshots().map((snapshot) {
      final tags = snapshot.docs.map((doc) => doc.data()).toList();
      tags.sort(
        (a, b) => (a['name'] ?? '').toString().compareTo(
          (b['name'] ?? '').toString(),
        ),
      );
      return tags;
    });
  }

  Stream<List<Map<String, dynamic>>> getTagsByCategory(String categoryId) {
    return _tags
        .where('isActive', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          final tags = snapshot.docs.map((doc) => doc.data()).toList();
          tags.sort(
            (a, b) => (a['name'] ?? '').toString().compareTo(
              (b['name'] ?? '').toString(),
            ),
          );
          return tags;
        });
  }

  Stream<List<Map<String, dynamic>>> getUncategorizedTags() {
    return _tags
        .where('isActive', isEqualTo: true)
        .where('categoryId', isNull: true)
        .snapshots()
        .map((snapshot) {
          final tags = snapshot.docs.map((doc) => doc.data()).toList();
          tags.sort(
            (a, b) => (a['name'] ?? '').toString().compareTo(
              (b['name'] ?? '').toString(),
            ),
          );
          return tags;
        });
  }

  Stream<List<String>> getAllTagNames() {
    return getAllTags().map(
      (tags) => tags
          .map((tag) => (tag['name'] ?? '').toString())
          .where((n) => n.isNotEmpty)
          .toList(),
    );
  }

  Stream<List<String>> getTagNamesByCategory(String categoryId) {
    return getTagsByCategory(categoryId).map(
      (tags) => tags
          .map((tag) => (tag['name'] ?? '').toString())
          .where((n) => n.isNotEmpty)
          .toList(),
    );
  }

  Stream<List<String>> getUncategorizedTagNames() {
    return getUncategorizedTags().map(
      (tags) => tags
          .map((tag) => (tag['name'] ?? '').toString())
          .where((n) => n.isNotEmpty)
          .toList(),
    );
  }
}
