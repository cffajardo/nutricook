import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/services/meal_reminder_scheduler.dart';
import 'package:nutricook/services/meal_window_helper.dart';
import 'package:nutricook/features/planner/util/nutrition_info_util.dart';

class PlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPlannerItem(
    PlannerItem item, {
    Map<String, int>? mealStartHours,
  }) async {
    // Firestore set() is essentially synchronous for local state
    _firestore
        .collection(FirestoreConstants.plannerItems)
        .doc(item.id)
        .set(_toFirestoreData(item));

    // Side effects should not block the UI
    _updateCalorieGoalNotification(item.ownerId, item.date);

    _scheduleReminders(item, mealStartHours);
  }

  void _scheduleReminders(PlannerItem item, Map<String, int>? mealStartHours) {
    try {
      MealReminderScheduler().scheduleMealReminder(
        plannerId: item.id,
        mealTime: item.date,
        mealName: item.recipeName,
        userId: item.ownerId,
      );

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

        MealReminderScheduler().scheduleMealWindowEndingReminder(
          mealType: item.mealType,
          mealWindowEndTime: adjustedEndTime,
          userId: item.ownerId,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling meal reminders: $e');
    }
  }

  Future<void> updatePlannerItem(
    PlannerItem item, {
    Map<String, int>? mealStartHours,
  }) async {
    _firestore
        .collection(FirestoreConstants.plannerItems)
        .doc(item.id)
        .update(_toFirestoreData(item));

    _updateCalorieGoalNotification(item.ownerId, item.date);

    try {
      MealReminderScheduler().cancelMealReminder(item.id);
      _scheduleReminders(item, mealStartHours);
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
    final docRef = _firestore.collection(FirestoreConstants.plannerItems).doc(id);
    
    // Get document using cache to avoid offline hang
    final doc = await docRef.get(const GetOptions(source: Source.serverAndCache));
    if (!doc.exists) return;
    
    final item = PlannerItem.fromJson(doc.data()!);
    
    docRef.delete();

    _updateCalorieGoalNotification(item.ownerId, item.date);

    try {
      MealReminderScheduler().cancelMealReminder(id);
    } catch (e) {
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

  Future<void> _updateCalorieGoalNotification(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Use serverAndCache but it will resolve immediately if data is in cache
      final snapshot = await _firestore
          .collection(FirestoreConstants.plannerItems)
          .where('ownerId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get(const GetOptions(source: Source.serverAndCache));

      final items = snapshot.docs.map((doc) => PlannerItem.fromJson(doc.data())).toList();
      final nutrition = calculatePlannerNutrition(plannerItems: items);
      
      // Fetch user goal from cache if offline
      final prefDoc = await _firestore.collection('userPreferences').doc(userId).get(const GetOptions(source: Source.serverAndCache));
      final goal = (prefDoc.data()?['dailyCalorieGoal'] as num?)?.toInt() ?? 2000;

      MealReminderScheduler().updateCalorieGoalReminder(
        userId: userId,
        date: date,
        currentCalories: nutrition.calories,
        goalCalories: goal,
      );
    } catch (e) {
      debugPrint('Error updating calorie goal notification: $e');
    }
  }
}
