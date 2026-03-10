import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

User requireAuthenticatedUser(FirebaseAuth auth) {
  final user = auth.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }
  return user;
}

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

