import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/firebase_messaging_service.dart';


final firebaseMessagingServiceProvider =
    Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});


final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final messagingService = ref.watch(firebaseMessagingServiceProvider);
  
  if (messagingService.fcmToken != null) {
    return messagingService.fcmToken;
  }

  return messagingService.refreshFCMToken();
});

final notificationsInitializedProvider = FutureProvider<bool>((ref) async {
  final messagingService = ref.watch(firebaseMessagingServiceProvider);
  return messagingService.isInitialized;
});
