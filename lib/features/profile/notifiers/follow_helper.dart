import 'package:flutter/material.dart';
import 'package:nutricook/services/notification_trigger.dart';

/// Helper for triggering follow notifications
/// This is integrated with the profile feature to send notifications when a user is followed
class FollowHelper {
  /// Call this when a user follows another user
  /// In a real app, this would be called from the user service or profile notifier
  static Future<bool> onUserFollowed({
    required String followerId,
    required String followerName,
    required String targetUserId,
    required String targetUserFcmToken,
  }) async {
    try {
      debugPrint('User followed: $followerName following $targetUserId');

      // Send notification
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

  /// INTEGRATION POINT:
  /// Add this call to your user/profile service follow method:
  ///
  /// In user_service.dart or profile notifier:
  /// ```
  /// Future<void> toggleFollowUser(String targetUserId) async {
  ///   final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  ///   
  ///   // ... existing follow logic (add to following list) ...
  ///   
  ///   // NEW: Send notification
  ///   await FollowHelper.onUserFollowed(
  ///     followerId: currentUserId!,
  ///     followerName: currentUserName,
  ///     targetUserId: targetUserId,
  ///     targetUserFcmToken: targetUserFcmToken, // fetch from Firestore
  ///   );
  /// }
  /// ```
}
