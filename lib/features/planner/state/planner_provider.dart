import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/planner/state/planner_notifier.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/services/planner_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/features/planner/util/nutrition_info_util.dart';


final plannerServiceProvider = Provider<PlannerService>((ref) {
  return PlannerService();
});


final plannerNotifierProvider =
    AsyncNotifierProvider<PlannerNotifier, List<PlannerItem>>(PlannerNotifier.new);

final selectedPlannerDateProvider = NotifierProvider.autoDispose<SelectedPlannerDateNotifier, DateTime>(SelectedPlannerDateNotifier.new);

final plannerItemsStreamProvider = StreamProvider<List<PlannerItem>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final selectedDate = ref.watch(selectedPlannerDateProvider);
  
  if (userId == null) return Stream.value([]);
  
  return ref.watch(plannerServiceProvider).getPlannerItemStream(userId, selectedDate);
});


final plannerItemsByMealTypeProvider =
    Provider.family<List<PlannerItem>, String>((ref, mealType) {
  final plannerItemsAsync = ref.watch(plannerNotifierProvider);
  
  return plannerItemsAsync.maybeWhen(
    data: (items) => items.where((item) => item.mealType == mealType).toList(),
    orElse: () => [],
  );
});

final dailyNutritionTotalProvider = Provider<NutritionInfo>((ref) {
  final plannerItems = ref.watch(plannerNotifierProvider).value ?? [];
  final recipes = ref.watch(filteredRecipesProvider).value ?? [];

  return calculatePlannerNutrition(plannerItems: plannerItems, recipes: recipes);
});