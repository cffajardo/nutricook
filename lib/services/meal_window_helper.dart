class MealWindowHelper {
  static const orderedMeals = [
    'Breakfast',
    'Morning Snack',
    'Lunch',
    'Afternoon Snack',
    'Dinner',
    'Evening Snack',
    'Other'
  ];

  static int getMealWindowEndTimeMinutes({
    required String mealType,
    required Map<String, int> mealStartHours,
  }) {
    final currentIndex = orderedMeals.indexOf(mealType);
    if (currentIndex == -1) return 1440; // 24:00

    for (int i = currentIndex + 1; i < orderedMeals.length; i++) {
      final nextMeal = orderedMeals[i];
      if (mealStartHours.containsKey(nextMeal)) {
        return mealStartHours[nextMeal] ?? 1440;
      }
    }

    return 1440; 
  }

  static DateTime getMealWindowEndDateTime({
    required String mealType,
    required Map<String, int> mealStartHours,
  }) {
    final now = DateTime.now();
    final endTimeMinutes = getMealWindowEndTimeMinutes(
      mealType: mealType,
      mealStartHours: mealStartHours,
    );

    final hours = endTimeMinutes ~/ 60;
    final minutes = endTimeMinutes % 60;

    var endDateTime = DateTime(now.year, now.month, now.day, hours, minutes);

    if (endDateTime.isBefore(now)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return endDateTime;
  }
}
