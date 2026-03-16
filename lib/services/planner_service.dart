import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/services/meal_reminder_scheduler.dart';
import 'package:nutricook/services/meal_window_helper.dart';

class PlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a planner item with meal reminders
  /// Optional: pass mealStartHours to schedule meal window ending reminder
  Future<void> addPlannerItem(
    PlannerItem item, {
    Map<String, int>? mealStartHours,
  }) async {
    await _firestore
        .collection(FirestoreConstants.plannerItems)
        .doc(item.id)
        .set(_toFirestoreData(item));

    // Schedule meal reminders
    try {
      // Schedule reminder at meal start time
      await MealReminderScheduler().scheduleMealReminder(
        plannerId: item.id,
        mealTime: item.date,
        mealName: item.recipeName,
        userId: item.ownerId,
      );

      // Schedule reminder 30 mins before meal window ends
      if (mealStartHours != null) {
        final windowEndTime = MealWindowHelper.getMealWindowEndDateTime(
          mealType: item.mealType,
          mealStartHours: mealStartHours,
        );

        // Adjust to same day as meal or next day if needed
        DateTime adjustedEndTime = DateTime(
          item.date.year,
          item.date.month,
          item.date.day,
          windowEndTime.hour,
          windowEndTime.minute,
        );

        // If end time is before meal time (past midnight), use next day
        if (adjustedEndTime.isBefore(item.date)) {
          adjustedEndTime = adjustedEndTime.add(const Duration(days: 1));
        }

        await MealReminderScheduler().scheduleMealWindowEndingReminder(
          mealType: item.mealType,
          mealWindowEndTime: adjustedEndTime,
          userId: item.ownerId,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling meal reminders: $e');
    }
  }

  /// Update a planner item with meal reminders
  /// Optional: pass mealStartHours to schedule meal window ending reminder
  Future<void> updatePlannerItem(
    PlannerItem item, {
    Map<String, int>? mealStartHours,
  }) async {
    await _firestore
        .collection(FirestoreConstants.plannerItems)
        .doc(item.id)
        .update(_toFirestoreData(item));

    // Reschedule meal reminders
    try {
      await MealReminderScheduler().cancelMealReminder(item.id);

      // Reschedule reminder at meal start time
      await MealReminderScheduler().scheduleMealReminder(
        plannerId: item.id,
        mealTime: item.date,
        mealName: item.recipeName,
        userId: item.ownerId,
      );

      // Reschedule reminder 30 mins before meal window ends
      if (mealStartHours != null) {
        final windowEndTime = MealWindowHelper.getMealWindowEndDateTime(
          mealType: item.mealType,
          mealStartHours: mealStartHours,
        );

        DateTime adjustedEndTime = DateTime(
          item.date.year,
          item.date.month,
          item.date.day,
          windowEndTime.hour,
          windowEndTime.minute,
        );

        if (adjustedEndTime.isBefore(item.date)) {
          adjustedEndTime = adjustedEndTime.add(const Duration(days: 1));
        }

        await MealReminderScheduler().scheduleMealWindowEndingReminder(
          mealType: item.mealType,
          mealWindowEndTime: adjustedEndTime,
          userId: item.ownerId,
        );
      }
    } catch (e) {
      debugPrint('Error rescheduling meal reminders: $e');
    }
  }

  Map<String, dynamic> _toFirestoreData(PlannerItem item) {
    final data = item.toJson();
    data['nutritionPerServing'] = item.nutritionPerServing?.toJson();
    return data;
  }

  Future<void> deletePlannerItem(String id) async {
    await _firestore.collection(FirestoreConstants.plannerItems).doc(id).delete();

    // Cancel the meal reminder for this item
    try {
      await MealReminderScheduler().cancelMealReminder(id);
    } catch (e) {
      // Log error but don't fail the planner item deletion
      debugPrint('Error canceling meal reminder: $e');
    }
  }

  Stream<List<PlannerItem>> getPlannerItemStream(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getPlannerItemsInRange(
      userId,
      startOfDay,
      endOfDay,
    );
  }

  Stream<List<PlannerItem>> getPlannerItemsInRange(
    String userId,
    DateTime startDate,
    DateTime endDateExclusive,
  ) {

    return _firestore
        .collection(FirestoreConstants.plannerItems)
        .where('ownerId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDateExclusive))
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PlannerItem.fromJson(doc.data())).toList(),
        );
  }

  Future<void> togglePlannerItemCompletion(String itemId, bool isCompleted) async {
    await _firestore
        .collection(FirestoreConstants.plannerItems)
        .doc(itemId)
        .update({'isCompleted': isCompleted});
  }
}
