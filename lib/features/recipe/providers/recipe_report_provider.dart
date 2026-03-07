import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/models/recipe_report/recipe_report.dart';
import 'package:nutricook/services/recipe_report_service.dart';

final recipeReportServiceProvider = Provider<RecipeReportService>((ref) {
  return RecipeReportService();
});

final recipeReportsProvider = StreamProvider.family<List<RecipeReport>, String>(
  (ref, recipeId) {
    return ref.watch(recipeReportServiceProvider).getReportsForRecipe(recipeId);
  },
);

final hasCurrentUserReportedRecipeProvider =
    FutureProvider.family<bool, String>((ref, recipeId) async {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) {
        return false;
      }

      return ref
          .watch(recipeReportServiceProvider)
          .hasUserReportedRecipe(recipeId, userId: userId);
    });

class ReportRecipeInput {
  const ReportRecipeInput({
    required this.recipeId,
    required this.reason,
    this.details,
  });

  final String recipeId;
  final String reason;
  final String? details;
}

final reportRecipeProvider = FutureProvider.autoDispose
    .family<void, ReportRecipeInput>((ref, input) async {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) {
        throw StateError('User must be signed in to report a recipe.');
      }

      await ref
          .read(recipeReportServiceProvider)
          .submitReport(
            recipeId: input.recipeId,
            reason: input.reason,
            details: input.details,
            reporterId: userId,
          );
    });
