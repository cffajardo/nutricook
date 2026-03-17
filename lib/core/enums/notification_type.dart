enum NotificationType {
  recipeLike('recipe_like'),
  follow('follow'),
  mealReminder('meal_reminder'),
  recipeDeleted('recipe_deleted'),
  calorieGoal('calorie_goal');

  final String value;

  const NotificationType(this.value);

  static NotificationType? fromString(String? value) {
    if (value == null) return null;
    try {
      return NotificationType.values.firstWhere(
        (type) => type.value == value,
      );
    } catch (e) {
      return null;
    }
  }


  bool get isRecipeRelated => this == NotificationType.recipeLike || this == NotificationType.recipeDeleted;
  bool get isSocial => this == NotificationType.follow;
  bool get isReminder => this == NotificationType.mealReminder || this == NotificationType.calorieGoal;
}
