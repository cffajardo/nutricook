import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/meal_time_preferences.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/service/user_preferences_service.dart';
import 'package:nutricook/models/user_preferences/user_preferences.dart';

final userPreferencesServiceProvider = Provider<UserPreferencesService>((ref) {
  return UserPreferencesService();
});

final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      UserPreferencesNotifier.new,
    );

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final preferences = ref.watch(userPreferencesProvider);
  return preferences.when(
    data: (value) => value.themeMode,
    loading: () => ThemeMode.system,
    error: (_, _) => ThemeMode.system,
  );
});

final mealStartHoursProvider = Provider<Map<String, int>>((ref) {
  final preferences = ref.watch(userPreferencesProvider).asData?.value;
  try {
    return sanitizeMealStartHours(preferences?.mealStartHours);
  } catch (_) {
    return defaultMealStartHours;
  }
});

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  UserPreferencesService get _service =>
      ref.read(userPreferencesServiceProvider);

  @override
  Future<UserPreferences> build() async {
    final uid = ref.watch(currentUserIdProvider);
    final localPreferences = await _service.loadPreferences(userId: uid);
    final remote = await _loadRemotePreferencesFromFirestore(uid);
    return localPreferences.copyWith(
      allergens: remote.allergens,
      mealStartHours: remote.mealStartHours,
      dailyCalorieGoal: remote.dailyCalorieGoal,
    );
  }

  Future<void> updateThemeMode(ThemeMode themeMode) {
    return _update((current) => current.copyWith(themeMode: themeMode));
  }

  Future<void> updateUnitSystem(UnitSystem unitSystem) {
    return _update((current) => current.copyWith(unitSystem: unitSystem));
  }

  Future<void> updateNotificationsEnabled(bool enabled) {
    return _update(
      (current) => current.copyWith(notificationsEnabled: enabled),
    );
  }

  Future<void> updateShowNutritionPerServing(bool enabled) {
    return _update(
      (current) => current.copyWith(showNutritionPerServing: enabled),
    );
  }

  Future<void> updateDailyCalorieGoal(int calories) {
    final sanitizedCalories = calories < 100 ? 100 : calories;
    return _update(
      (current) => current.copyWith(dailyCalorieGoal: sanitizedCalories),
    );
  }

  Future<void> updateAllergens(List<String> allergens) {
    return _update((current) => current.copyWith(allergens: allergens));
  }

  Future<void> updateShowRecipesWithAllergens(bool enabled) {
    return _update(
      (current) => current.copyWith(showRecipesWithAllergens: enabled),
    );
  }

  Future<void> updateMealStartHour(String mealType, int minutesValue) {
    return _update((current) {
      final validatedHours = validateAndClampMealTimes(
        current.mealStartHours,
        mealType,
        minutesValue,
      );
      return current.copyWith(mealStartHours: validatedHours);
    });
  }

  Future<void> resetToDefaults() async {
    final defaults = UserPreferences.defaults;
    final uid = ref.read(currentUserIdProvider);
    await _service.savePreferences(defaults, userId: uid);
    await _syncRemotePreferencesToFirestore(
      allergens: defaults.allergens,
      mealStartHours: defaults.mealStartHours,
      dailyCalorieGoal: defaults.dailyCalorieGoal,
    );
    state = AsyncData(defaults);
  }

  Future<void> _update(UserPreferences Function(UserPreferences) mutate) async {
    final uid = ref.read(currentUserIdProvider);
    final currentState = state;
    final current = currentState is AsyncData<UserPreferences>
        ? currentState.value
        : await _service.loadPreferences(userId: uid);
    final updated = mutate(current);

    state = AsyncData(updated);
    await _service.savePreferences(updated, userId: uid);

    final didAllergensChange = !_stringListEquals(
      current.allergens,
      updated.allergens,
    );
    final didMealStartHoursChange = !_intMapEquals(
      current.mealStartHours,
      updated.mealStartHours,
    );
    final didDailyCalorieGoalChange =
        current.dailyCalorieGoal != updated.dailyCalorieGoal;

    if (didAllergensChange ||
        didMealStartHoursChange ||
        didDailyCalorieGoalChange) {
      await _syncRemotePreferencesToFirestore(
        allergens: didAllergensChange ? updated.allergens : null,
        mealStartHours: didMealStartHoursChange ? updated.mealStartHours : null,
        dailyCalorieGoal: didDailyCalorieGoalChange
            ? updated.dailyCalorieGoal
            : null,
      );
    }
  }

  Future<void> _syncRemotePreferencesToFirestore({
    List<String>? allergens,
    Map<String, int>? mealStartHours,
    int? dailyCalorieGoal,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null || uid.trim().isEmpty) {
      return;
    }

    final update = <String, dynamic>{};

    if (allergens != null) {
      final normalizedAllergens =
          allergens
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      update['allergens'] = normalizedAllergens;
    }

    if (mealStartHours != null) {
      update['mealStartHours'] = sanitizeMealStartHours(mealStartHours);
    }

    if (dailyCalorieGoal != null) {
      final normalizedCalories = dailyCalorieGoal < 100
          ? 100
          : dailyCalorieGoal;
      update['dailyCalorieGoal'] = normalizedCalories;
    }

    if (update.isEmpty) {
      return;
    }

    try {
      // Sync to separate userPreferences collection instead of main user doc
      // This prevents preference updates from triggering router re-evaluation
      await FirebaseFirestore.instance
          .collection('userPreferences')
          .doc(uid)
          .set(update, SetOptions(merge: true));
    } catch (_) {
      // Ignore remote sync failures to avoid blocking local UI updates.
    }
  }

  Future<_RemotePreferenceValues> _loadRemotePreferencesFromFirestore(
    String? uid,
  ) async {
    if (uid == null || uid.trim().isEmpty) {
      return _RemotePreferenceValues.defaults();
    }

    try {
      // Load from separate userPreferences collection to avoid coupling with user doc
      final snapshot = await FirebaseFirestore.instance
          .collection('userPreferences')
          .doc(uid)
          .get();
      final data = snapshot.data();
      if (data == null) {
        return _RemotePreferenceValues.defaults();
      }

      final rawAllergens = data['allergens'];
      final allergens = rawAllergens is List
          ? (rawAllergens
                .map((item) => item.toString().trim())
                .where((item) => item.isNotEmpty)
                .toSet()
                .toList()
              ..sort())
          : const <String>[];

      final rawMealStartHours = data['mealStartHours'];
      final mealStartHours = rawMealStartHours is Map
          ? sanitizeMealStartHours(
              rawMealStartHours.map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value as num?)?.toInt() ??
                      defaultMealStartHours[key.toString()] ??
                      0,
                ),
              ),
            )
          : defaultMealStartHours;

      final dailyCalorieGoal =
          (data['dailyCalorieGoal'] as num?)?.toInt() ??
          UserPreferences.defaults.dailyCalorieGoal;

      return _RemotePreferenceValues(
        allergens: allergens,
        mealStartHours: mealStartHours,
        dailyCalorieGoal: dailyCalorieGoal < 100 ? 100 : dailyCalorieGoal,
      );
    } catch (_) {
      return _RemotePreferenceValues.defaults();
    }
  }

  bool _stringListEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _intMapEquals(Map<String, int> a, Map<String, int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}

class _RemotePreferenceValues {
  const _RemotePreferenceValues({
    required this.allergens,
    required this.mealStartHours,
    required this.dailyCalorieGoal,
  });

  final List<String> allergens;
  final Map<String, int> mealStartHours;
  final int dailyCalorieGoal;

  factory _RemotePreferenceValues.defaults() {
    return const _RemotePreferenceValues(
      allergens: <String>[],
      mealStartHours: defaultMealStartHours,
      dailyCalorieGoal: 2000,
    );
  }
}
