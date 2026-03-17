import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nutricook/core/enums/notification_type.dart';

class MealReminderScheduler {
  static final MealReminderScheduler _instance =
      MealReminderScheduler._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory MealReminderScheduler() {
    return _instance;
  }

  MealReminderScheduler._internal();

  Future<int> scheduleMealReminder({
    required String plannerId,
    required DateTime mealTime,
    required String mealName,
    required String userId,
  }) async {
    try {
      debugPrint('Scheduling meal reminder for $mealName at $mealTime');

      final notificationId = plannerId.hashCode.abs();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'meal_reminder_notification_channel',
        'Meal Reminders',
        channelDescription: 'Channel for meal reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      const DarwinNotificationDetails iOSDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      final payload = _createPayload(
        type: NotificationType.mealReminder,
        plannerId: plannerId,
        userId: userId,
      );

      final delayDuration = mealTime.difference(DateTime.now());
      
      if (delayDuration.isNegative) {
        return notificationId;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Meal Reminder',
        'Time to have: $mealName',
        _getZonedDateTime(mealTime),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('Meal reminder scheduled with ID: $notificationId');
      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling meal reminder: $e');
      rethrow;
    }
  }

  Future<int?> scheduleMealWindowEndingReminder({
    required String mealType,
    required DateTime mealWindowEndTime,
    required String userId,
  }) async {
    try {
      debugPrint(
          'Scheduling meal window ending reminder for $mealType at $mealWindowEndTime');

      final reminderTime = mealWindowEndTime.subtract(const Duration(minutes: 30));

      final delayDuration = reminderTime.difference(DateTime.now());

      if (delayDuration.isNegative) {
        debugPrint('Reminder time is in the past, skipping scheduling');
        return null;
      }

      final notificationId = ('${mealType}_ending_$userId').hashCode.abs();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'meal_reminder_notification_channel',
        'Meal Reminders',
        channelDescription: 'Channel for meal reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      const DarwinNotificationDetails iOSDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      final payload = _createPayload(
        type: NotificationType.mealReminder,
        plannerId: mealType,
        userId: userId,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '$mealType ending soon',
        'Your $mealType window is closing in 30 minutes',
        _getZonedDateTime(reminderTime),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('Meal window ending reminder scheduled with ID: $notificationId');
      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling meal window ending reminder: $e');
      return null;
    }
  }

  Future<void> updateCalorieGoalReminder({
    required String userId,
    required DateTime date,
    required int currentCalories,
    required int goalCalories,
  }) async {
    try {
      final dateStr = '${date.year}-${date.month}-${date.day}';
      final notificationId = ('calorie_goal_${userId}_$dateStr').hashCode.abs();

      if (currentCalories >= goalCalories) {
        await _flutterLocalNotificationsPlugin.cancel(notificationId);
        debugPrint('Calorie goal reached ($currentCalories/$goalCalories). Cancelled 11 PM reminder for $dateStr');
        return;
      }

      final reminderTime = DateTime(date.year, date.month, date.day, 23, 0);
      
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint('Calorie goal reminder time for $dateStr has already passed.');
        return;
      }

      debugPrint('Scheduling calorie goal reminder for $dateStr at 11:00 PM. Current: $currentCalories, Goal: $goalCalories');

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'calorie_goal_notification_channel',
        'Daily Goals',
        channelDescription: 'Channel for daily calorie goal reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      final payload = _createPayload(
        type: NotificationType.calorieGoal,
        plannerId: dateStr,
        userId: userId,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Daily Calorie Goal',
        "You haven't hit your calorie goal yet! ($currentCalories/$goalCalories kcal)",
        _getZonedDateTime(reminderTime),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      debugPrint('Calorie goal reminder scheduled with ID: $notificationId');
    } catch (e) {
      debugPrint('Error updating calorie goal reminder: $e');
    }
  }

  dynamic _getZonedDateTime(DateTime dateTime) {
    return dateTime;
  }

  Future<void> cancelMealReminder(String plannerId) async {
    try {
      final notificationId = plannerId.hashCode.abs();
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('Meal reminder cancelled for plannerId: $plannerId');
    } catch (e) {
      debugPrint('Error cancelling meal reminder: $e');
    }
  }


  Future<void> cancelAllMealReminders() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All meal reminders cancelled');
    } catch (e) {
      debugPrint('Error cancelling all meal reminders: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isMealReminderScheduled(String plannerId) async {
    try {
      final notificationId = plannerId.hashCode.abs();
      final pending = await getPendingReminders();
      return pending.any((notification) => notification.id == notificationId);
    } catch (e) {
      return false;
    }
  }

  Future<void> createNotificationChannel() async {
    try {
      const AndroidNotificationChannel mealReminderChannel =
          AndroidNotificationChannel(
        'meal_reminder_notification_channel',
        'Meal Reminders',
        description: 'Channel for meal reminder notifications',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(mealReminderChannel);

      const AndroidNotificationChannel calorieGoalChannel =
          AndroidNotificationChannel(
        'calorie_goal_notification_channel',
        'Daily Goals',
        description: 'Channel for daily calorie goal reminders',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(calorieGoalChannel);

      debugPrint('Meal reminder notification channel created');
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  String _createPayload({
    required NotificationType type,
    required String plannerId,
    required String userId,
  }) {
    return '${type.value}:$plannerId:$userId';
  }

  static Map<String, String> parsePayload(String payload) {
    try {
      final parts = payload.split(':');
      if (parts.length < 3) return {};

      return {
        'type': parts[0],
        'plannerId': parts[1],
        'userId': parts[2],
      };
    } catch (e) {
      return {};
    }
  }
}
