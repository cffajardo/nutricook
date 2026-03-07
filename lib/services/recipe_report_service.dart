import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/recipe_report/recipe_report.dart';

class RecipeReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitReport({
    required String recipeId,
    required String reason,
    String? details,
    String? reporterId,
  }) async {
    final uid = reporterId ?? _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User must be signed in to report a recipe.');
    }

    final now = DateTime.now();
    final reportId = _reportDocId(recipeId, uid);
    final reportRef = _db
        .collection(FirestoreConstants.recipeReports)
        .doc(reportId);
    final recipeRef = _db.collection(FirestoreConstants.recipes).doc(recipeId);

    await _db.runTransaction((transaction) async {
      final recipeSnapshot = await transaction.get(recipeRef);
      if (!recipeSnapshot.exists) {
        throw StateError('Recipe not found.');
      }

      final reportSnapshot = await transaction.get(reportRef);
      if (reportSnapshot.exists) {
        transaction.update(reportRef, <String, dynamic>{
          'reason': reason,
          'details': details,
          'status': 'open',
          'updatedAt': Timestamp.fromDate(now),
        });
        return;
      }

      final report = RecipeReport(
        id: reportId,
        recipeId: recipeId,
        reporterId: uid,
        reason: reason,
        details: details,
        status: 'open',
        createdAt: now,
        updatedAt: now,
      );

      transaction.set(reportRef, report.toJson());
      transaction.update(recipeRef, <String, dynamic>{
        'reportCount': FieldValue.increment(1),
      });
    });
  }

  Future<bool> hasUserReportedRecipe(String recipeId, {String? userId}) async {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) {
      return false;
    }

    final reportId = _reportDocId(recipeId, uid);
    final doc = await _db
        .collection(FirestoreConstants.recipeReports)
        .doc(reportId)
        .get();
    return doc.exists;
  }

  Stream<List<RecipeReport>> getReportsForRecipe(String recipeId) {
    return _db
        .collection(FirestoreConstants.recipeReports)
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RecipeReport.fromJson(doc.data()))
              .toList();
        });
  }

  String _reportDocId(String recipeId, String userId) {
    return '${recipeId}_$userId';
  }
}
