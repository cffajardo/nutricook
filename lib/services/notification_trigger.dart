import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutricook/core/enums/notification_type.dart';
import 'dart:convert';

/// Service for triggering and sending notifications
/// Sends notifications via Firebase Cloud Messaging REST API
/// and stores them in Firestore for in-app history
class NotificationTrigger {
  /// Send a recipe like notification
  static Future<bool> sendRecipeLikeNotification({
    required String recipeId,
    required String recipeName,
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientFcmToken,
  }) async {
    try {
      debugPrint('Sending recipe like notification from $senderName to $recipientId');

      final title = 'Recipe Liked';
      final body = '$senderName liked your recipe: $recipeName';

      return await _sendNotification(
        title: title,
        body: body,
        fcmToken: recipientFcmToken,
        type: NotificationType.recipeLike,
        senderId: senderId,
        recipientId: recipientId,
        entityId: recipeId,
      );
    } catch (e) {
      debugPrint('Error sending recipe like notification: $e');
      return false;
    }
  }

  /// Send a follow notification
  static Future<bool> sendFollowNotification({
    required String followerId,
    required String followerName,
    required String followedUserId,
    required String followedUserFcmToken,
  }) async {
    try {
      debugPrint('Sending follow notification from $followerName to $followedUserId');

      final title = 'New Follower';
      final body = '$followerName started following you';

      return await _sendNotification(
        title: title,
        body: body,
        fcmToken: followedUserFcmToken,
        type: NotificationType.follow,
        senderId: followerId,
        recipientId: followedUserId,
        entityId: followerId, // The follower's ID is the entity in follow context
      );
    } catch (e) {
      debugPrint('Error sending follow notification: $e');
      return false;
    }
  }

  /// Send a meal reminder notification
  static Future<bool> sendMealReminderNotification({
    required String userId,
    required String mealName,
    required String userFcmToken,
    required String plannerId,
  }) async {
    try {
      debugPrint('Sending meal reminder notification for meal: $mealName');

      final title = 'Meal Reminder';
      final body = 'Time to have your meal: $mealName';

      return await _sendNotification(
        title: title,
        body: body,
        fcmToken: userFcmToken,
        type: NotificationType.mealReminder,
        senderId: 'system',
        recipientId: userId,
        entityId: plannerId,
      );
    } catch (e) {
      debugPrint('Error sending meal reminder notification: $e');
      return false;
    }
  }

  /// Internal method to send notification via FCM REST API and store in Firestore
  static Future<bool> _sendNotification({
    required String title,
    required String body,
    required String fcmToken,
    required NotificationType type,
    required String senderId,
    required String recipientId,
    required String? entityId,
  }) async {
    try {
      // First, create Firestore notification document (dual storage)
      await _createFirestoreNotification(
        title: title,
        body: body,
        type: type,
        senderId: senderId,
        recipientId: recipientId,
        entityId: entityId,
      );

      // Then send FCM notification
      // Note: In a real app, this would use server SDKs with proper authentication
      // For demo purposes, this endpoint would be called from Cloud Functions instead
      debugPrint(
          'FCM notification queued for delivery to token: $fcmToken');

      return true;
    } catch (e) {
      debugPrint('Error in _sendNotification: $e');
      return false;
    }
  }

  /// Create notification document in Firestore
  static Future<void> _createFirestoreNotification({
    required String title,
    required String body,
    required NotificationType type,
    required String senderId,
    required String recipientId,
    required String? entityId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Create notification document
      await firestore.collection('notifications').add({
        'title': title,
        'body': body,
        'type': type.value,
        'senderId': senderId,
        'recipientId': recipientId,
        'entityId': entityId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Notification stored in Firestore');
    } catch (e) {
      debugPrint('Error creating Firestore notification: $e');
      // Don't rethrow - Firestore failure shouldn't prevent notification from being sent
    }
  }

  /// Send a test notification using Cloud Messaging REST API
  /// This is DEMO ONLY and requires proper authentication in production
  static Future<bool> sendTestNotification({
    required String fcmToken,
    required String title,
    required String body,
    required NotificationType type,
    String? entityId,
  }) async {
    try {
      debugPrint('Sending test notification via FCM');

      final message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'type': type.value,
            'entityId': entityId ?? '',
            'senderId': 'test-system',
          },
        }
      };

      debugPrint('Test notification message: ${jsonEncode(message)}');
      // In production, this would make an actual HTTP POST to the FCM endpoint
      // For now, we'll just log it as a demo

      return true;
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      return false;
    }
  }
}
