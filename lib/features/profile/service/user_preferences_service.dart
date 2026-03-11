import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutricook/core/meal_time_preferences.dart';
import 'package:nutricook/models/user_preferences/user_preferences.dart';

class UserPreferencesService {
  static const String _legacyStorageKey = 'user_preferences_v1';
  static const String _storageKeyPrefix = 'user_preferences_v2';
  static const Set<String> _remoteOnlyFields = <String>{
    'allergens',
    'mealStartHours',
    'dailyCalorieGoal',
  };

  Future<UserPreferences> loadPreferences({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await _sanitizeAllStoredPreferences(prefs);

    final storageKey = _storageKeyFor(userId);
    var raw = prefs.getString(storageKey);

    // One-time migration from the legacy global key to per-user storage.
    if ((raw == null || raw.trim().isEmpty) && userId != null) {
      final legacyRaw = prefs.getString(_legacyStorageKey);
      if (legacyRaw != null && legacyRaw.trim().isNotEmpty) {
        final sanitizedLegacyRaw = _sanitizeStoredJson(legacyRaw);
        await prefs.setString(storageKey, sanitizedLegacyRaw);
        await prefs.remove(_legacyStorageKey);
        raw = sanitizedLegacyRaw;
      }
    }

    if (raw == null || raw.trim().isEmpty) {
      return UserPreferences.defaults;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final parsed = UserPreferences.fromJson(decoded);
        return parsed;
      }
      if (decoded is Map) {
        final parsed = UserPreferences.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
        return parsed;
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
    final encoded = jsonEncode(
      preferences
          .copyWith(
            allergens: const <String>[],
            mealStartHours: defaultMealStartHours,
            dailyCalorieGoal: UserPreferences.defaults.dailyCalorieGoal,
          )
          .toJson(),
    );
    await prefs.setString(_storageKeyFor(userId), encoded);
    await _sanitizeAllStoredPreferences(prefs);
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

  Future<void> _sanitizeAllStoredPreferences(SharedPreferences prefs) async {
    final keys = prefs
        .getKeys()
        .where(
          (key) => key == _legacyStorageKey || key.startsWith(_storageKeyPrefix),
        )
        .toList(growable: false);

    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw == null || raw.trim().isEmpty) {
        continue;
      }

      final sanitized = _sanitizeStoredJson(raw);
      if (sanitized != raw) {
        await prefs.setString(key, sanitized);
      }
    }
  }

  String _sanitizeStoredJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return raw;
      }

      final data = decoded.map((key, value) => MapEntry(key.toString(), value));
      var changed = false;
      for (final field in _remoteOnlyFields) {
        if (data.remove(field) != null) {
          changed = true;
        }
      }

      if (!changed) {
        return raw;
      }
      return jsonEncode(data);
    } catch (_) {
      return raw;
    }
  }
}
