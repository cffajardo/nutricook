import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/firebase_messaging_service.dart';

/// Provider for FirebaseMessagingService instance
final firebaseMessagingServiceProvider =
    Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});

/// Provider for FCM token retrieval
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final messagingService = ref.watch(firebaseMessagingServiceProvider);
  
  // Try to get existing token
  if (messagingService.fcmToken != null) {
    return messagingService.fcmToken;
  }
  
  // Otherwise refresh it
  return messagingService.refreshFCMToken();
});

/// Provider for checking if notifications are initialized
final notificationsInitializedProvider = FutureProvider<bool>((ref) async {
  final messagingService = ref.watch(firebaseMessagingServiceProvider);
  return messagingService.isInitialized;
});
