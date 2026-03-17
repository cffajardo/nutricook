import 'package:flutter/material.dart';
import 'package:nutricook/services/notification_trigger.dart';

class FollowHelper {
  static Future<bool> onUserFollowed({
    required String followerId,
    required String followerName,
    required String targetUserId,
    required String targetUserFcmToken,
  }) async {
    try {
      debugPrint('User followed: $followerName following $targetUserId');

      return await NotificationTrigger.sendFollowNotification(
        followerId: followerId,
        followerName: followerName,
        followedUserId: targetUserId,
        followedUserFcmToken: targetUserFcmToken,
      );
    } catch (e) {
      debugPrint('Error handling follow: $e');
      return false;
    }
  }
}
