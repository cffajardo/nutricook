import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/services/meal_reminder_scheduler.dart';

class PlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPlannerItem(PlannerItem item) async {
    await _firestore
        .collection(FirestoreConstants.plannerItems)
        .doc(item.id)
        .set(_toFirestoreData(item));

    // Schedule a meal reminder for this item
    try {
      await MealReminderScheduler().scheduleMealReminder(
        plannerId: item.id,
        mealTime: item.date,
        mealName: item.recipeName,
        userId: item.ownerId,
      );
    } catch (e) {
      // Log error but don't fail the planner item creation
      debugPrint('Error scheduling meal reminder: $e');
    }
  }

  Future<void> updatePlannerItem(PlannerItem item) async {
    await _firestore
        .collection(FirestoreConstants.plannerItems)
        .doc(item.id)
        .update(_toFirestoreData(item));

    // Reschedule the meal reminder for this item
    try {
      await MealReminderScheduler().cancelMealReminder(item.id);
      await MealReminderScheduler().scheduleMealReminder(
        plannerId: item.id,
        mealTime: item.date,
        mealName: item.recipeName,
        userId: item.ownerId,
      );
    } catch (e) {
      // Log error but don't fail the planner item update
      debugPrint('Error rescheduling meal reminder: $e');
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
