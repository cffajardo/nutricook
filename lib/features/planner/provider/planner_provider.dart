import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/services/planner_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/features/planner/util/nutrition_info_util.dart';


final plannerServiceProvider = Provider<PlannerService>((ref) {
  return PlannerService();
});

final plannerItemsForDateProvider = StreamProvider.family<List<PlannerItem>, DateTime>((ref, selectedDate) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return Stream.value([]);
  
  return ref.watch(plannerServiceProvider).getPlannerItemStream(userId, selectedDate);
});


final plannerItemsByMealTypeProvider =
    Provider.family<List<PlannerItem>, ({DateTime date, String mealType})>((ref, input) {
  final items = ref.watch(plannerItemsForDateProvider(input.date)).value ?? [];
  return items.where((item) => item.mealType == input.mealType).toList();
});

final dailyNutritionTotalProvider = Provider.family<AsyncValue<NutritionInfo>, DateTime>((ref, date) {
  final plannerItemsAsync = ref.watch(plannerItemsForDateProvider(date));
  return plannerItemsAsync.whenData((plannerItems) {
    return calculatePlannerNutrition(plannerItems: plannerItems);
  });
});