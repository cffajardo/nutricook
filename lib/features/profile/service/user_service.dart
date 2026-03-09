import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestoreConstants.users);

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<void> updateUserAllergens(String uid, String newAllergen) async {
    await _users.doc(uid).update({
      'allergens': FieldValue.arrayUnion([newAllergen]),
    });
  }

  Future<void> removeUserAllergen(String uid, String allergenToRemove) async {
    await _users.doc(uid).update({
      'allergens': FieldValue.arrayRemove([allergenToRemove]),
    });
  }

  Future<List<String>> getUserAllergens(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['allergens'] is List) {
        return List<String>.from(data['allergens']);
      }
    }
    return [];
  }

  Future<void> deleteUserAccount(String uid) async {
    await _users.doc(uid).delete();
  }

  // Stream for user allergens (used in recipe filtering to apply allergen filters in real-time)
  Stream<List<String>> getUserAllergensStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['allergens'] is List) {
          return List<String>.from(data['allergens']);
        }
      }
      return [];
    });
  }

  // Stream for user data (used in profile screen to listen for real-time updates)
  Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data();
      }
      return null;
    });
  }

  Stream<List<String>> getFollowingIdsStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || data['following'] is! List) return <String>[];
      return List<String>.from(data['following']);
    });
  }

  Stream<List<String>> getBlockedUserIdsStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || data['blockedUsers'] is! List) return <String>[];
      return List<String>.from(data['blockedUsers']);
    });
  }

  Stream<List<Map<String, dynamic>>> getDiscoverUsersStream({
    required String currentUserId,
    String query = '',
    int limit = 50,
  }) {
    final normalized = query.trim().toLowerCase();

    return _users.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data())
          .where((user) => user['id'] != currentUserId)
          .where((user) {
            if (normalized.isEmpty) return true;
            final username = (user['username'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();
            return username.contains(normalized) || email.contains(normalized);
          })
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUsersByIdsStream(List<String> ids) {
    if (ids.isEmpty) return Stream.value(<Map<String, dynamic>>[]);

    return _users.snapshots().map((snapshot) {
      final wanted = ids.toSet();
      return snapshot.docs
          .map((doc) => doc.data())
          .where((user) => wanted.contains(user['id']))
          .toList();
    });
  }

  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (currentUserId == targetUserId) return;

    final currentRef = _users.doc(currentUserId);
    final targetRef = _users.doc(targetUserId);

    await _db.runTransaction((txn) async {
      final currentSnap = await txn.get(currentRef);
      final targetSnap = await txn.get(targetRef);

      if (!currentSnap.exists || !targetSnap.exists) {
        throw Exception('User document not found.');
      }

      final currentData = currentSnap.data() ?? <String, dynamic>{};
      final targetData = targetSnap.data() ?? <String, dynamic>{};

      final currentBlocked = List<String>.from(
        currentData['blockedUsers'] ?? [],
      );
      final targetBlocked = List<String>.from(targetData['blockedUsers'] ?? []);

      if (currentBlocked.contains(targetUserId) ||
          targetBlocked.contains(currentUserId)) {
        throw Exception('Cannot follow a blocked user.');
      }

      txn.update(currentRef, {
        'following': FieldValue.arrayUnion([targetUserId]),
      });
      txn.update(targetRef, {
        'followers': FieldValue.arrayUnion([currentUserId]),
      });
    });
  }

  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (currentUserId == targetUserId) return;

    final currentRef = _users.doc(currentUserId);
    final targetRef = _users.doc(targetUserId);

    final batch = _db.batch();
    batch.update(currentRef, {
      'following': FieldValue.arrayRemove([targetUserId]),
    });
    batch.update(targetRef, {
      'followers': FieldValue.arrayRemove([currentUserId]),
    });
    await batch.commit();
  }

  Future<void> blockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (currentUserId == targetUserId) return;

    final currentRef = _users.doc(currentUserId);
    final targetRef = _users.doc(targetUserId);

    final batch = _db.batch();
    batch.update(currentRef, {
      'blockedUsers': FieldValue.arrayUnion([targetUserId]),
      'following': FieldValue.arrayRemove([targetUserId]),
      'followers': FieldValue.arrayRemove([targetUserId]),
    });
    batch.update(targetRef, {
      'blockedBy': FieldValue.arrayUnion([currentUserId]),
      'following': FieldValue.arrayRemove([currentUserId]),
      'followers': FieldValue.arrayRemove([currentUserId]),
    });
    await batch.commit();
  }

  Future<void> unblockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (currentUserId == targetUserId) return;

    final currentRef = _users.doc(currentUserId);
    final targetRef = _users.doc(targetUserId);

    final batch = _db.batch();
    batch.update(currentRef, {
      'blockedUsers': FieldValue.arrayRemove([targetUserId]),
    });
    batch.update(targetRef, {
      'blockedBy': FieldValue.arrayRemove([currentUserId]),
    });
    await batch.commit();
  }
}
