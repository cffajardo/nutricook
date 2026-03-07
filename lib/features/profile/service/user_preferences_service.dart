import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutricook/models/user_preferences/user_preferences.dart';

class UserPreferencesService {
  static const String _storageKey = 'user_preferences_v1';

  Future<UserPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return UserPreferences.defaults;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserPreferences.fromJson(decoded);
      }
      if (decoded is Map) {
        return UserPreferences.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
      return UserPreferences.defaults;
    } catch (_) {
      return UserPreferences.defaults;
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(preferences.toJson());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
