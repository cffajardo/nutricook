import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutricook/core/enums/notification_type.dart';

class NotificationTrigger {
  static Future<bool> sendRecipeLikeNotification({
    required String recipeId,
    required String recipeName,
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientFcmToken,
  }) async {
    try {


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
        entityId: followerId, 
      );
    } catch (e) {
      debugPrint('Error sending follow notification: $e');
      return false;
    }
  }

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

  static Future<bool> sendRecipeDeletedNotification({
    required String recipeId,
    required String recipeName,
    required String recipeOwnerId,
    required String ownerFcmToken,
    required String reason,
  }) async {
    try {
      debugPrint('Sending recipe deleted notification for recipe: $recipeName');

      final title = 'Recipe Removed';
      final body = 'Your recipe "$recipeName" was removed due to: $reason';

      return await _sendNotification(
        title: title,
        body: body,
        fcmToken: ownerFcmToken,
        type: NotificationType.recipeDeleted,
        senderId: 'system',
        recipientId: recipeOwnerId,
        entityId: recipeId,
      );
    } catch (e) {
      debugPrint('Error sending recipe deleted notification: $e');
      return false;
    }
  }

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
      await _createFirestoreNotification(
        title: title,
        body: body,
        type: type,
        senderId: senderId,
        recipientId: recipientId,
        entityId: entityId,
      );

      debugPrint(
          'FCM notification queued for delivery to token: $fcmToken');

      return true;
    } catch (e) {
      debugPrint('Error in _sendNotification: $e');
      return false;
    }
  }

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
      //
    }
  }

}
