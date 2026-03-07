import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    error: (_, __) => ThemeMode.system,
  );
});

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  UserPreferencesService get _service =>
      ref.read(userPreferencesServiceProvider);

  @override
  Future<UserPreferences> build() {
    return _service.loadPreferences();
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

  Future<void> resetToDefaults() async {
    final defaults = UserPreferences.defaults;
    await _service.savePreferences(defaults);
    state = AsyncData(defaults);
  }

  Future<void> _update(UserPreferences Function(UserPreferences) mutate) async {
    final currentState = state;
    final current =
        currentState is AsyncData<UserPreferences>
            ? currentState.value
            : await _service.loadPreferences();
    final updated = mutate(current);

    state = AsyncData(updated);
    await _service.savePreferences(updated);
  }
}
