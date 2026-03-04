import 'package:nutricook/features/profile/service/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';


final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Stream Provider for current user's data (Requires user ID from auth provider)
final userDataProvider = StreamProvider((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  
  final userService = ref.watch(userServiceProvider);
  return userService.getUserDataStream(userId);
});

// Stream Provider for current user's allergens 
final userAllergenProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(currentUserIdProvider);

  if (uid == null) {
    return Stream.value(<String>[]);
  }

  final userService = ref.read(userServiceProvider);
  return userService.getUserAllergensStream(uid);
});






