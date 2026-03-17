import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/models/notification_payload.dart';
import 'package:nutricook/core/enums/notification_type.dart';
import 'package:nutricook/routing/app_routes.dart';

class NotificationHandler {
  static Future<void> handleNotificationTap({
    required BuildContext context,
    required NotificationPayload payload,
  }) async {
    try {
      debugPrint('Handling notification tap for type: ${payload.type}');

      switch (payload.type) {
        case NotificationType.recipeLike:
          _handleRecipeLikeNotification(context, payload);
          break;
        case NotificationType.follow:
          _handleFollowNotification(context, payload);
          break;
        case NotificationType.mealReminder:
          _handleMealReminderNotification(context, payload);
          break;
        case NotificationType.recipeDeleted:
          break;
        case NotificationType.calorieGoal:
          // No action for calorie goal notification
          break;
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  static void _handleRecipeLikeNotification(
    BuildContext context,
    NotificationPayload payload,
  ) {
    if (payload.entityId == null) {
      debugPrint('Recipe like notification missing entityId');
      return;
    }

    if (context.mounted) {
      debugPrint('Navigating to recipe: ${payload.entityId}');
      context.pushNamed(
        AppRoutes.recipeDetailsName,
        extra: {'recipeId': payload.entityId},
      );
    }
  }

  static void _handleFollowNotification(
    BuildContext context,
    NotificationPayload payload,
  ) {
    if (payload.senderId == null) {
      debugPrint('Follow notification missing senderId');
      return;
    }

    if (context.mounted) {
      debugPrint('Navigating to user profile: ${payload.senderId}');
      context.pushNamed(
        AppRoutes.profileUserName,
        pathParameters: {'userId': payload.senderId!},
      );
    }
  }

  static void _handleMealReminderNotification(
    BuildContext context,
    NotificationPayload payload,
  ) {
    if (context.mounted) {
      debugPrint('Navigating to meal planner for reminder');
      context.pushNamed(AppRoutes.plannerName);
    }
  }
}
