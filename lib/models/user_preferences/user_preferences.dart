import 'package:flutter/material.dart';

enum UnitSystem { metric, imperial }

class UserPreferences {
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.unitSystem = UnitSystem.metric,
    this.notificationsEnabled = true,
    this.showOnlyVerifiedRecipes = false,
    this.showNutritionPerServing = true,
    this.dailyCalorieGoal = 2000,
  });

  final ThemeMode themeMode;
  final UnitSystem unitSystem;
  final bool notificationsEnabled;
  final bool showOnlyVerifiedRecipes;
  final bool showNutritionPerServing;
  final int dailyCalorieGoal;

  static const UserPreferences defaults = UserPreferences();

  UserPreferences copyWith({
    ThemeMode? themeMode,
    UnitSystem? unitSystem,
    bool? notificationsEnabled,
    bool? showOnlyVerifiedRecipes,
    bool? showNutritionPerServing,
    int? dailyCalorieGoal,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      unitSystem: unitSystem ?? this.unitSystem,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      showOnlyVerifiedRecipes:
          showOnlyVerifiedRecipes ?? this.showOnlyVerifiedRecipes,
      showNutritionPerServing:
          showNutritionPerServing ?? this.showNutritionPerServing,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'unitSystem': unitSystem.name,
      'notificationsEnabled': notificationsEnabled,
      'showOnlyVerifiedRecipes': showOnlyVerifiedRecipes,
      'showNutritionPerServing': showNutritionPerServing,
      'dailyCalorieGoal': dailyCalorieGoal,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    ThemeMode? parsedThemeMode;
    for (final mode in ThemeMode.values) {
      if (mode.name == json['themeMode']) {
        parsedThemeMode = mode;
        break;
      }
    }

    UnitSystem? parsedUnitSystem;
    for (final unit in UnitSystem.values) {
      if (unit.name == json['unitSystem']) {
        parsedUnitSystem = unit;
        break;
      }
    }

    final calorieGoal =
        (json['dailyCalorieGoal'] as num?)?.toInt() ??
        UserPreferences.defaults.dailyCalorieGoal;

    return UserPreferences(
      themeMode: parsedThemeMode ?? UserPreferences.defaults.themeMode,
      unitSystem: parsedUnitSystem ?? UserPreferences.defaults.unitSystem,
      notificationsEnabled:
          json['notificationsEnabled'] as bool? ??
          UserPreferences.defaults.notificationsEnabled,
      showOnlyVerifiedRecipes:
          json['showOnlyVerifiedRecipes'] as bool? ??
          UserPreferences.defaults.showOnlyVerifiedRecipes,
      showNutritionPerServing:
          json['showNutritionPerServing'] as bool? ??
          UserPreferences.defaults.showNutritionPerServing,
      dailyCalorieGoal: calorieGoal < 100 ? 100 : calorieGoal,
    );
  }
}
