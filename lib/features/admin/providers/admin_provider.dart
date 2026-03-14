import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_report_provider.dart';
import 'package:nutricook/models/recipe_report/recipe_report.dart';

final adminReportsProvider =
    StreamProvider.family<List<RecipeReport>, String>((ref, status) {
      return ref.watch(recipeReportServiceProvider).getAllReports(status: status);
    });

final adminUsersCountProvider = Provider<int>((ref) {
  return ref.watch(adminUsersQueryProvider('')).asData?.value.length ?? 0;
});

final adminBannedUsersCountProvider = Provider<int>((ref) {
  final users = ref.watch(adminUsersQueryProvider('')).asData?.value;
  if (users == null) return 0;
  return users.where((user) => user['isBanned'] == true).length;
});

final adminOpenReportsCountProvider = Provider<int>((ref) {
  return ref.watch(adminReportsProvider('open')).asData?.value.length ?? 0;
});

final adminIngredientsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, query) {
      final normalized = query.trim().toLowerCase();
      return FirebaseFirestore.instance
          .collection(FirestoreConstants.ingredients)
          .orderBy('name')
          .limit(400)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
                .where((ingredient) {
                  if (normalized.isEmpty) return true;
                  final name =
                      (ingredient['name'] ?? '').toString().toLowerCase();
                  final category =
                      (ingredient['category'] ?? '').toString().toLowerCase();
                  return name.contains(normalized) ||
                      category.contains(normalized);
                })
                .toList(growable: false);
          });
    });

final adminRecipesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, query) {
      final normalized = query.trim().toLowerCase();
      return FirebaseFirestore.instance
          .collection(FirestoreConstants.recipes)
          .orderBy('createdAt', descending: true)
          .limit(400)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
                .where((recipe) {
                  if (normalized.isEmpty) return true;
                  final name = (recipe['name'] ?? '').toString().toLowerCase();
                  final description =
                      (recipe['description'] ?? '').toString().toLowerCase();
                  return name.contains(normalized) ||
                      description.contains(normalized);
                })
                .toList(growable: false);
          });
    });

final adminIngredientsCountProvider = Provider<int>((ref) {
  return ref.watch(adminIngredientsProvider('')).asData?.value.length ?? 0;
});

final adminRecipesCountProvider = Provider<int>((ref) {
  return ref.watch(adminRecipesProvider('')).asData?.value.length ?? 0;
});

final adminRecipeNameProvider =
    FutureProvider.family<String?, String>((ref, recipeId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection(FirestoreConstants.recipes)
        .doc(recipeId)
        .get();
    return doc.data()?['name'] as String?;
  } catch (_) {
    return null;
  }
});
