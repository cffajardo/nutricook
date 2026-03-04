import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Require that a FirebaseAuth user is currently signed in.
/// Throws a standardized exception if not.
User requireAuthenticatedUser(FirebaseAuth auth) {
  final user = auth.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }
  return user;
}

/// Ensure that a Firestore document exists and is owned by `expectedOwnerId`.
/// The document is expected to have an `ownerId` field.
Future<void> ensureOwner({
  required DocumentReference<Map<String, dynamic>> ref,
  required String expectedOwnerId,
}) async {
  final snapshot = await ref.get();

  if (!snapshot.exists) {
    throw Exception('Document not found');
  }

  final data = snapshot.data();
  if (data == null || data['ownerId'] != expectedOwnerId) {
    throw Exception('Unauthorized');
  }
}

