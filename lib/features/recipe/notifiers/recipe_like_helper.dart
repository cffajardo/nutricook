import 'package:flutter/material.dart';
import 'package:nutricook/services/notification_trigger.dart';

/// Helper for triggering recipe like notifications
/// This is integrated with the recipe feature to send notifications when a recipe is liked
class RecipeLikeHelper {
  /// Call this when a user likes a recipe
  /// In a real app, this would be called from the laning recipe service
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

      // Send notification
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

  /// INTEGRATION POINT:
  /// Add this call to your recipe service like button handler:
  ///
  /// In recipe_service.dart or recipe notifier:
  /// ```
  /// Future<void> toggleRecipeLike(String recipeId) async {
  ///   // ... existing like logic ...
  ///   
  ///   // NEW: Send notification
  ///   await RecipeLikeHelper.onRecipeLiked(
  ///     recipeId: recipeId,
  ///     recipeName: recipe.name,
  ///     likerId: currentUserId,
  ///     likerName: currentUserName,
  ///     recipeOwnerId: recipe.userId,
  ///     ownerFcmToken: ownerFcmToken, // fetch from Firestore
  ///   );
  /// }
  /// ```
}
