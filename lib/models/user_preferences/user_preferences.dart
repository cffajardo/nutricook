import 'package:flutter/material.dart';
import 'package:nutricook/core/meal_time_preferences.dart';

enum UnitSystem { metric, imperial }

class UserPreferences {
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.unitSystem = UnitSystem.metric,
    this.notificationsEnabled = true,
    this.showNutritionPerServing = true,
    this.dailyCalorieGoal = 2000,
    this.allergens = const <String>[],
    this.showRecipesWithAllergens = true,
    this.mealStartHours = defaultMealStartHours,
  });

  final ThemeMode themeMode;
  final UnitSystem unitSystem;
  final bool notificationsEnabled;
  final bool showNutritionPerServing;
  final int dailyCalorieGoal;
  final List<String> allergens;
  final bool showRecipesWithAllergens;
  final Map<String, int> mealStartHours;

  static const UserPreferences defaults = UserPreferences();

  UserPreferences copyWith({
    ThemeMode? themeMode,
    UnitSystem? unitSystem,
    bool? notificationsEnabled,
    bool? showNutritionPerServing,
    int? dailyCalorieGoal,
    List<String>? allergens,
    bool? showRecipesWithAllergens,
    Map<String, int>? mealStartHours,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      unitSystem: unitSystem ?? this.unitSystem,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      showNutritionPerServing:
          showNutritionPerServing ?? this.showNutritionPerServing,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      allergens: allergens ?? this.allergens,
      showRecipesWithAllergens:
          showRecipesWithAllergens ?? this.showRecipesWithAllergens,
      mealStartHours: sanitizeMealStartHours(
        mealStartHours ?? this.mealStartHours,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'themeMode': themeMode.name,
      'unitSystem': unitSystem.name,
      'notificationsEnabled': notificationsEnabled,
      'showNutritionPerServing': showNutritionPerServing,
      'dailyCalorieGoal': dailyCalorieGoal,
      'allergens': allergens,
      'showRecipesWithAllergens': showRecipesWithAllergens,
      'mealStartHours': mealStartHours,
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

    final parsedMealStartHours = sanitizeMealStartHours(
      (json['mealStartHours'] as Map?)?.map(
        (key, value) => MapEntry(
          key.toString(),
          (value as num?)?.toInt() ??
              defaultMealStartHours[key.toString()] ??
              0,
        ),
      ),
    );

    return UserPreferences(
      themeMode: parsedThemeMode ?? UserPreferences.defaults.themeMode,
      unitSystem: parsedUnitSystem ?? UserPreferences.defaults.unitSystem,
      notificationsEnabled:
          json['notificationsEnabled'] as bool? ??
          UserPreferences.defaults.notificationsEnabled,
      showNutritionPerServing:
          json['showNutritionPerServing'] as bool? ??
          UserPreferences.defaults.showNutritionPerServing,
      dailyCalorieGoal: calorieGoal < 100 ? 100 : calorieGoal,
      allergens: (json['allergens'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
      showRecipesWithAllergens:
          json['showRecipesWithAllergens'] as bool? ??
          UserPreferences.defaults.showRecipesWithAllergens,
      mealStartHours: parsedMealStartHours,
    );
  }
}
