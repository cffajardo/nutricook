/// Types of notifications that can be sent
enum NotificationType {
  recipeLike('recipe_like'),
  follow('follow'),
  mealReminder('meal_reminder'),
  recipeDeleted('recipe_deleted');

  final String value;

  const NotificationType(this.value);

  /// Convert string to NotificationType
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

  /// Check if this is a recipe-related notification
  bool get isRecipeRelated => this == NotificationType.recipeLike || this == NotificationType.recipeDeleted;

  /// Check if this is a social notification
  bool get isSocial => this == NotificationType.follow;

  /// Check if this is a reminder notification
  bool get isReminder => this == NotificationType.mealReminder;
}
