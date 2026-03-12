import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/services/planner_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/features/planner/util/nutrition_info_util.dart';

// Service provider for PlannerService
final plannerServiceProvider = Provider<PlannerService>((ref) {
  return PlannerService();
});

// Stream of planner items for a specific date (Only for single day for now)
final plannerItemsForDateProvider = StreamProvider.family<List<PlannerItem>, DateTime>((ref, selectedDate) {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return Stream.value([]);
  
  return ref.watch(plannerServiceProvider).getPlannerItemStream(userId, selectedDate);
});

final plannerItemsForMonthProvider =
    StreamProvider.family<List<PlannerItem>, DateTime>((ref, selectedDate) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) return Stream.value([]);

      final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
      final nextMonthStart = DateTime(selectedDate.year, selectedDate.month + 1, 1);

      return ref
          .watch(plannerServiceProvider)
          .getPlannerItemsInRange(userId, monthStart, nextMonthStart);
    });

// Filtered planner items by meal type (breakfast, lunch, dinner, snacks)
final plannerItemsByMealTypeProvider =
    Provider.family<List<PlannerItem>, ({DateTime date, String mealType})>((ref, input) {
  final items = ref.watch(plannerItemsForDateProvider(input.date)).value ?? [];
  return items.where((item) => item.mealType == input.mealType).toList();
});


// Daily nutrition total for the day based on planner items
final dailyNutritionTotalProvider = Provider.family<AsyncValue<NutritionInfo>, DateTime>((ref, date) {
  final plannerItemsAsync = ref.watch(plannerItemsForDateProvider(date));
  return plannerItemsAsync.whenData((plannerItems) {
    return calculatePlannerNutrition(plannerItems: plannerItems);
  });
});

final monthlyNutritionTotalProvider =
    Provider.family<AsyncValue<NutritionInfo>, DateTime>((ref, date) {
      final plannerItemsAsync = ref.watch(plannerItemsForMonthProvider(date));
      return plannerItemsAsync.whenData((plannerItems) {
        return calculatePlannerNutrition(plannerItems: plannerItems);
      });
    });