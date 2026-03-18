import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/recipe_report/recipe_report.dart';

class RecipeReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Set<String> _allowedStatuses = <String>{
    'open',
    'reviewed',
    'dismissed',
    'archived',
  };

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

    try {
      // Fetch status using serverAndCache to avoid hanging offline
      final recipeSnapshot = await recipeRef.get(const GetOptions(source: Source.serverAndCache));
      if (!recipeSnapshot.exists) {
        throw StateError('Recipe not found.');
      }

      final reportSnapshot = await reportRef.get(const GetOptions(source: Source.serverAndCache));
      
      final batch = _db.batch();
      if (reportSnapshot.exists) {
        batch.update(reportRef, <String, dynamic>{
          'reason': reason,
          'details': details,
          'status': 'open',
          'updatedAt': Timestamp.fromDate(now),
        });
      } else {
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

        batch.set(reportRef, report.toJson());
        batch.update(recipeRef, <String, dynamic>{
          'reportCount': FieldValue.increment(1),
        });
      }
      batch.commit(); // Non-blocking for offline functionality
    } catch (e) {
      //
    }
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

  Stream<List<RecipeReport>> getAllReports({
    String status = '',
    int limit = 300,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection(FirestoreConstants.recipeReports)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final normalizedStatus = status.trim().toLowerCase();
    if (normalizedStatus.isNotEmpty) {
      query = query.where('status', isEqualTo: normalizedStatus);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeReport.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    String? reviewedBy,
    String? reviewNote,
  }) async {
    final normalizedStatus = status.trim().toLowerCase();
    if (!_allowedStatuses.contains(normalizedStatus)) {
      throw ArgumentError('Invalid report status: $status');
    }

    final now = DateTime.now();
    final reportRef = _db
        .collection(FirestoreConstants.recipeReports)
        .doc(reportId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(reportRef);
      if (!snapshot.exists) {
        throw StateError('Report not found.');
      }

      transaction.update(reportRef, <String, dynamic>{
        'status': normalizedStatus,
        'reviewedBy': reviewedBy,
        'reviewNote': reviewNote,
        'reviewedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
    });
  }

  Future<void> setRecipeVisibility({
    required String recipeId,
    required bool isPublic,
  }) async {
    final recipeRef = _db.collection(FirestoreConstants.recipes).doc(recipeId);
    final snapshot = await recipeRef.get();
    if (!snapshot.exists) {
      throw StateError('Recipe not found.');
    }

    await recipeRef.update(<String, dynamic>{
      'isPublic': isPublic,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteRecipe({required String recipeId}) async {
    final recipeRef = _db.collection(FirestoreConstants.recipes).doc(recipeId);
    final snapshot = await recipeRef.get();
    if (!snapshot.exists) {
      throw StateError('Recipe not found.');
    }

 
    await _db.runTransaction((transaction) async {
      transaction.delete(recipeRef);

      final reportsQuery = _db
          .collection(FirestoreConstants.recipeReports)
          .where('recipeId', isEqualTo: recipeId);

      final reportSnapshot = await reportsQuery.get();
      for (final reportDoc in reportSnapshot.docs) {
        transaction.delete(reportDoc.reference);
      }
    });
  }

  Future<void> deleteReport({required String reportId}) async {
    await _db
        .collection(FirestoreConstants.recipeReports)
        .doc(reportId)
        .delete();
  }

  String _reportDocId(String recipeId, String userId) {
    return '${recipeId}_$userId';
  }
}
