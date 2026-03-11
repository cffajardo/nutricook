import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
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
    final firestoreAllergens = await _loadAllergensFromFirestore(uid);
    return localPreferences.copyWith(allergens: firestoreAllergens);
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

  Future<void> updateShowOnlyVerifiedRecipes(bool enabled) {
    return _update(
      (current) => current.copyWith(showOnlyVerifiedRecipes: enabled),
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

  Future<void> updateMealStartHour(String mealType, int hour) {
    return _update((current) {
      final updatedHours = Map<String, int>.from(current.mealStartHours)
        ..[mealType] = hour.clamp(0, 23).toInt();
      return current.copyWith(
        mealStartHours: sanitizeMealStartHours(updatedHours),
      );
    });
  }

  Future<void> resetToDefaults() async {
    final defaults = UserPreferences.defaults;
    final uid = ref.read(currentUserIdProvider);
    await _service.savePreferences(defaults, userId: uid);
    await _syncAllergensToFirestore(defaults.allergens);
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
    if (!_stringListEquals(current.allergens, updated.allergens)) {
      await _syncAllergensToFirestore(updated.allergens);
    }
  }

  Future<void> _syncAllergensToFirestore(List<String> allergens) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      return;
    }

    final normalized =
        allergens
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.users)
          .doc(uid)
          .set(<String, dynamic>{
            'allergens': normalized,
          }, SetOptions(merge: true));
    } catch (_) {
      // Ignore remote sync failures to avoid blocking local UI updates.
    }
  }

  Future<List<String>> _loadAllergensFromFirestore(String? uid) async {
    if (uid == null || uid.trim().isEmpty) {
      return const <String>[];
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.users)
          .doc(uid)
          .get();
      final data = snapshot.data();
      final raw = data?['allergens'];
      if (raw is! List) {
        return const <String>[];
      }

      return raw
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } catch (_) {
      return const <String>[];
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
}
