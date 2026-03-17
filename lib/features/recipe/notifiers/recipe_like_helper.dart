import 'package:flutter/material.dart';
import 'package:nutricook/services/notification_trigger.dart';


class RecipeLikeHelper {
  static Future<bool> onRecipeLiked({
    required String recipeId,
    required String recipeName,
    required String likerId,
    required String likerName,
    required String recipeOwnerId,
    required String ownerFcmToken,
  }) async {
    try {
      debugPrint('Recipe liked: $recipeName by $likerName');

      return await NotificationTrigger.sendRecipeLikeNotification(
        recipeId: recipeId,
        recipeName: recipeName,
        senderId: likerId,
        senderName: likerName,
        recipientId: recipeOwnerId,
        recipientFcmToken: ownerFcmToken,
      );
    } catch (e) {
      debugPrint('Error handling recipe like: $e');
      return false;
    }
  }
}
