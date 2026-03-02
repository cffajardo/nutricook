// ignore_for_file: unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<void> updateUserAllergens(String uid, String newAllergen) async {
    await _db.collection('users').doc(uid).update({'allergens': FieldValue.arrayUnion([newAllergen])});
  }

  Future<void> removeUserAllergen(String uid, String allergenToRemove) async {
    await _db.collection('users').doc(uid).update({'allergens': FieldValue.arrayRemove([allergenToRemove])});
  }

  Future<List<String>> getUserAllergens(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['allergens'] is List) {
        return List<String>.from(data['allergens']);
      }
    }
    return [];
  }

  Future<void> deleteUserAccount(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  Stream<List<String>> getUserAllergensStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['allergens'] is List) {
          return List<String>.from(data['allergens']);
        }
      }
      return [];
    });
  }

  Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data();
      }
      return null;
    });
  }


}