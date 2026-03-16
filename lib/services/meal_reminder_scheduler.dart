import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nutricook/core/enums/notification_type.dart';

/// Service for scheduling local notifications for meal reminders
class MealReminderScheduler {
  static final MealReminderScheduler _instance =
      MealReminderScheduler._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory MealReminderScheduler() {
    return _instance;
  }

  MealReminderScheduler._internal();

  /// Schedule a meal reminder notification at the specified time
  /// Returns the notification ID used for scheduling
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

      // Create payload for notification tap
      final payload = _createPayload(
        type: NotificationType.mealReminder,
        plannerId: plannerId,
        userId: userId,
      );

      // For demo purposes, use simple scheduling with millisecondsSinceEpoch
      // In production, use timezone package for proper timezone handling
      final delayDuration = mealTime.difference(DateTime.now());
      
      if (delayDuration.isNegative) {
        debugPrint('Meal time is in the past, skipping scheduling');
        return notificationId;
      }

      // Schedule the notification
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

  /// Schedule a meal window ending reminder (30 mins before meal window ends)
  /// This provides a second reminder when the meal time window is about to close
  Future<int?> scheduleMealWindowEndingReminder({
    required String mealType,
    required DateTime mealWindowEndTime,
    required String userId,
  }) async {
    try {
      debugPrint(
          'Scheduling meal window ending reminder for $mealType at $mealWindowEndTime');

      // Schedule reminder 30 minutes before the window ends
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

  /// Get a TZDateTime using the simple approach
  /// This is a workaround for demo purposes without timezone package
  dynamic _getZonedDateTime(DateTime dateTime) {
    // Use the DateTime directly - flutter_local_notifications handles timezone conversion
    return dateTime;
  }

  /// Cancel a scheduled meal reminder
  Future<void> cancelMealReminder(String plannerId) async {
    try {
      final notificationId = plannerId.hashCode.abs();
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('Meal reminder cancelled for plannerId: $plannerId');
    } catch (e) {
      debugPrint('Error cancelling meal reminder: $e');
    }
  }

  /// Cancel all meal reminders
  Future<void> cancelAllMealReminders() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All meal reminders cancelled');
    } catch (e) {
      debugPrint('Error cancelling all meal reminders: $e');
    }
  }

  /// Get pending notifications (useful for checking scheduled reminders)
  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending reminders: $e');
      return [];
    }
  }

  /// Check if a specific meal reminder is scheduled
  Future<bool> isMealReminderScheduled(String plannerId) async {
    try {
      final notificationId = plannerId.hashCode.abs();
      final pending = await getPendingReminders();
      return pending.any((notification) => notification.id == notificationId);
    } catch (e) {
      debugPrint('Error checking meal reminder: $e');
      return false;
    }
  }

  /// Create notification channel for Android 8+
  /// Call this during app initialization
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

      debugPrint('Meal reminder notification channel created');
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  /// Create notification payload for deep linking on tap
  String _createPayload({
    required NotificationType type,
    required String plannerId,
    required String userId,
  }) {
    // Format: type:plannerId:userId
    return '${type.value}:$plannerId:$userId';
  }

  /// Parse notification payload
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
      debugPrint('Error parsing notification payload: $e');
      return {};
    }
  }
}
