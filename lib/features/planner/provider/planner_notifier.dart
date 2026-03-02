import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class PlannerNotifier extends AsyncNotifier<List<PlannerItem>> {

 @override
  Future<List<PlannerItem>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];

    final items = await ref.watch(plannerItemsStreamProvider.future);
    return items;
  }

  Future<void> addPlannerItem(PlannerItem item) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    await ref.read(plannerServiceProvider).addPlannerItem(item);
    return [...state.value ?? [], item];
  });
}

Future<void> deletePlannerItem(String id) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    await ref.read(plannerServiceProvider).deletePlannerItem(id);
    return state.value?.where((i) => i.id != id).toList() ?? [];
  });
}

Future<void> updatePlannerItem(PlannerItem item) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    await ref.read(plannerServiceProvider).updatePlannerItem(item);
    return state.value?.map((i) => i.id == item.id ? item : i).toList() ?? [];
  });
}

Future<void> togglePlannerItemCompletion(String itemId, bool isCompleted) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    await ref.read(plannerServiceProvider).togglePlannerItemCompletion(itemId, isCompleted);
    return state.value?.map((i) =>
      i.id == itemId ? i.copyWith(isCompleted: isCompleted) : i
    ).toList() ?? [];
  });
}
}

class SelectedPlannerDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setDate(DateTime date) {
    state = date;
  }

  void goToPreviousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  void goToNextDay() {
    state = state.add(const Duration(days: 1));
  }
}
