import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/techniques/techniques.dart';

class TechniqueService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Technique>> getAllTechniques() async {
    final snapshot = await _db
        .collection(FirestoreConstants.techniques)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Technique.fromJson(doc.data()))
        .toList();
  }

  Future<Technique?> getTechniqueById(String techniqueId) async {
    final doc = await _db
        .collection(FirestoreConstants.techniques)
        .doc(techniqueId)
        .get();

    if (!doc.exists) return null;
    return Technique.fromJson(doc.data()!);
  }
}

