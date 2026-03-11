import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutricook/core/meal_time_preferences.dart';
import 'package:nutricook/models/user_preferences/user_preferences.dart';

class UserPreferencesService {
  static const String _legacyStorageKey = 'user_preferences_v1';
  static const String _storageKeyPrefix = 'user_preferences_v2';

  Future<UserPreferences> loadPreferences({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = _storageKeyFor(userId);
    var raw = prefs.getString(storageKey);

    // One-time migration from the legacy global key to per-user storage.
    if ((raw == null || raw.trim().isEmpty) && userId != null) {
      final legacyRaw = prefs.getString(_legacyStorageKey);
      if (legacyRaw != null && legacyRaw.trim().isNotEmpty) {
        await prefs.setString(storageKey, legacyRaw);
        await prefs.remove(_legacyStorageKey);
        raw = legacyRaw;
      }
    }

    if (raw == null || raw.trim().isEmpty) {
      return UserPreferences.defaults;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final parsed = UserPreferences.fromJson(decoded);
        // Self-heal malformed older payloads (for example null mealStartHours).
        return parsed.copyWith(
          mealStartHours: sanitizeMealStartHours(parsed.mealStartHours),
        );
      }
      if (decoded is Map) {
        final parsed = UserPreferences.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
        return parsed.copyWith(
          mealStartHours: sanitizeMealStartHours(parsed.mealStartHours),
        );
      }
      return UserPreferences.defaults;
    } catch (_) {
      return UserPreferences.defaults;
    }
  }

  Future<void> savePreferences(
    UserPreferences preferences, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(preferences.toJson());
    await prefs.setString(_storageKeyFor(userId), encoded);
  }

  Future<void> clearPreferences({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKeyFor(userId));
  }

  String _storageKeyFor(String? userId) {
    final normalizedUserId = (userId ?? '').trim();
    if (normalizedUserId.isEmpty) {
      return '${_storageKeyPrefix}_guest';
    }
    return '${_storageKeyPrefix}_$normalizedUserId';
  }
}
