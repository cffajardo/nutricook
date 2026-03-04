import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/nutrition/nutrition.dart';

class NutritionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Nutrition>> getAllNutritionDetails() async {
    final snapshot = await _db
        .collection(FirestoreConstants.nutrition)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Nutrition.fromJson(doc.data()))
        .toList();
  }

  Future<Nutrition?> getNutritionDetailById(String nutritionId) async {
    final doc = await _db
        .collection(FirestoreConstants.nutrition)
        .doc(nutritionId)
        .get();

    if (!doc.exists) return null;
    return Nutrition.fromJson(doc.data()!);
  }
}

