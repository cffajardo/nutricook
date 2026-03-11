import 'package:nutricook/features/profile/service/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';

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

final userDataByIdProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, userId) {
      final userService = ref.watch(userServiceProvider);
      return userService.getUserDataStream(userId);
    });

// Stream Provider for current user's allergens
final userAllergenProvider = StreamProvider<List<String>>((ref) {
  final preferences = ref.watch(userPreferencesProvider).asData?.value;
  return Stream.value(preferences?.allergens ?? const <String>[]);
});

final userFollowingIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(<String>[]);
  return ref.watch(userServiceProvider).getFollowingIdsStream(uid);
});

final blockedUserIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(<String>[]);
  return ref.watch(userServiceProvider).getBlockedUserIdsStream(uid);
});

final discoverUsersProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, query) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null) return Stream.value(<Map<String, dynamic>>[]);
      return ref
          .watch(userServiceProvider)
          .getDiscoverUsersStream(currentUserId: uid, query: query);
    });

final followingUsersProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final idsAsync = ref.watch(userFollowingIdsProvider);
  final ids = idsAsync.asData?.value ?? <String>[];
  return ref.watch(userServiceProvider).getUsersByIdsStream(ids);
});

final blockedUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final idsAsync = ref.watch(blockedUserIdsProvider);
  final ids = idsAsync.asData?.value ?? <String>[];
  return ref.watch(userServiceProvider).getUsersByIdsStream(ids);
});

final followersUsersForCurrentUserProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final userData = ref.watch(userDataProvider).asData?.value;
      final ids = userData is Map<String, dynamic>
          ? _extractConnectionIds(userData['followers'])
          : <String>[];
      return ref.watch(userServiceProvider).getUsersByIdsStream(ids);
    });

final followingUsersForCurrentUserProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final userData = ref.watch(userDataProvider).asData?.value;
      final ids = userData is Map<String, dynamic>
          ? _extractConnectionIds(userData['following'])
          : <String>[];
      return ref.watch(userServiceProvider).getUsersByIdsStream(ids);
    });

final followersUsersForCurrentUserQueryProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null || uid.isEmpty) {
        return Stream.value(<Map<String, dynamic>>[]);
      }
      return ref.watch(userServiceProvider).getFollowersOfUserStream(uid);
    });

final followingUsersForCurrentUserQueryProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null || uid.isEmpty) {
        return Stream.value(<Map<String, dynamic>>[]);
      }
      return ref.watch(userServiceProvider).getFollowingOfUserStream(uid);
    });

final followersUsersForCurrentUserFutureProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null || uid.isEmpty) return <Map<String, dynamic>>[];
      return ref.watch(userServiceProvider).getFollowersOfUserOnce(uid);
    });

final followingUsersForCurrentUserFutureProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null || uid.isEmpty) return <Map<String, dynamic>>[];
      return ref.watch(userServiceProvider).getFollowingOfUserOnce(uid);
    });

final followersUsersByUserIdProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      final userDataAsync = ref.watch(userDataByIdProvider(userId));
      final userData = userDataAsync.asData?.value;
      final ids = userData == null
          ? <String>[]
          : _extractConnectionIds(userData['followers']);
      return ref.watch(userServiceProvider).getUsersByIdsStream(ids);
    });

final followingUsersByUserIdProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      final userDataAsync = ref.watch(userDataByIdProvider(userId));
      final userData = userDataAsync.asData?.value;
      final ids = userData == null
          ? <String>[]
          : _extractConnectionIds(userData['following']);
      return ref.watch(userServiceProvider).getUsersByIdsStream(ids);
    });

final followersUsersByUserIdQueryProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      if (userId.trim().isEmpty) return Stream.value(<Map<String, dynamic>>[]);
      return ref.watch(userServiceProvider).getFollowersOfUserStream(userId);
    });

final followingUsersByUserIdQueryProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      if (userId.trim().isEmpty) return Stream.value(<Map<String, dynamic>>[]);
      return ref.watch(userServiceProvider).getFollowingOfUserStream(userId);
    });

List<String> _extractConnectionIds(dynamic rawList) {
  final values = rawList as List<dynamic>? ?? const <dynamic>[];
  return values
      .map((entry) {
        if (entry is String) {
          return _normalizeConnectionToken(entry);
        }

        if (entry is Map) {
          final map = entry.cast<dynamic, dynamic>();
          final candidates = [
            map['reference'],
            entry['id'],
            entry['uid'],
            entry['userId'],
            entry['path'],
            entry['username'],
            entry['email'],
          ];

          for (final value in candidates) {
            final text = _normalizeConnectionToken(value?.toString());
            if (text.isNotEmpty) return text;
          }
          return '';
        }

        return _normalizeConnectionToken(entry.toString());
      })
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList(growable: false);
}

String _normalizeConnectionToken(String? raw) {
  final text = (raw ?? '').trim();
  if (text.isEmpty) return '';

  // Handles values like:
  // - users/{uid}
  // - DocumentReference<Map<String, dynamic>>(users/{uid})
  // - projects/.../documents/users/{uid}
  final usersIndex = text.lastIndexOf('users/');
  if (usersIndex >= 0) {
    final candidate = text.substring(usersIndex + 'users/'.length).trim();
    final cleaned = candidate
        .split(RegExp(r'[)\\s/]+'))
        .firstWhere((part) => part.isNotEmpty, orElse: () => '');
    if (cleaned.isNotEmpty) return cleaned;
  }

  return text;
}
