const List<String> orderedMealTypes = <String>[
  'Breakfast',
  'Lunch',
  'Snack',
  'Dinner',
  'Other',
];

// Store as minutes (0-1439) to support both hours and minutes
const Map<String, int> defaultMealStartHours = <String, int>{
  'Breakfast': 5 * 60, // 5:00 AM
  'Lunch': 11 * 60, // 11:00 AM
  'Snack': 15 * 60, // 3:00 PM
  'Dinner': 18 * 60, // 6:00 PM
  'Other': 22 * 60, // 10:00 PM
};

Map<String, int> sanitizeMealStartHours(Map<String, int>? hours) {
  return <String, int>{
    for (final mealType in orderedMealTypes)
      mealType: (hours?[mealType] ?? defaultMealStartHours[mealType]!)
          .clamp(0, 1439) // 0-1439 minutes in a day
          .toInt(),
  };
}

String resolveMealTypeForTime(DateTime time, Map<String, int>? hours) {
  final sanitized = sanitizeMealStartHours(hours);
  final currentMinutes = (time.hour * 60) + time.minute;
  final slots = orderedMealTypes.asMap().entries.map((entry) {
    return _MealTimeSlot(
      mealType: entry.value,
      startMinutes: sanitized[entry.value]!,
      index: entry.key,
    );
  }).toList()
    ..sort((a, b) {
      final startComparison = a.startMinutes.compareTo(b.startMinutes);
      if (startComparison != 0) {
        return startComparison;
      }
      return a.index.compareTo(b.index);
    });

  var active = slots.last;
  for (final slot in slots) {
    if (currentMinutes >= slot.startMinutes) {
      active = slot;
      continue;
    }
    break;
  }

  return active.mealType;
}

String formatMealHourLabel(int minutes) {
  final normalized = minutes.clamp(0, 1439);
  final hour = normalized ~/ 60;
  final min = normalized % 60;
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final suffix = hour < 12 ? 'AM' : 'PM';
  return '$displayHour:${min.toString().padLeft(2, '0')} $suffix';
}

bool isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Validates that meal times are in chronological order (no overlaps).
/// "Other" can be set at any time and has no ordering constraints.
/// Returns the validated map or the original if no overlaps would occur.
/// If an overlap is detected, the new time is clamped to prevent it.
Map<String, int> validateAndClampMealTimes(
  Map<String, int> mealTimes,
  String mealTypeBeingChanged,
  int newTime,
) {
  final result = Map<String, int>.from(mealTimes);
  result[mealTypeBeingChanged] = newTime.clamp(0, 1439);

  // "Other" can be at any time, no validation needed
  if (mealTypeBeingChanged == 'Other') {
    return sanitizeMealStartHours(result);
  }

  // Get the index of the meal being changed
  final changedIndex = orderedMealTypes.indexOf(mealTypeBeingChanged);
  if (changedIndex == -1) return sanitizeMealStartHours(result);

  // Check if it violates ordering with previous meal (skip if prev is "Other")
  if (changedIndex > 0) {
    final prevMealType = orderedMealTypes[changedIndex - 1];
    if (prevMealType != 'Other') {
      final prevTime = result[prevMealType]!;
      if (result[mealTypeBeingChanged]! < prevTime) {
        result[mealTypeBeingChanged] = prevTime;
      }
    }
  }

  // Check if it violates ordering with next meal (skip if next is "Other")
  if (changedIndex < orderedMealTypes.length - 1) {
    final nextMealType = orderedMealTypes[changedIndex + 1];
    if (nextMealType != 'Other') {
      final nextTime = result[nextMealType]!;
      if (result[mealTypeBeingChanged]! > nextTime) {
        result[mealTypeBeingChanged] = nextTime;
      }
    }
  }

  return sanitizeMealStartHours(result);
}

class _MealTimeSlot {
  const _MealTimeSlot({
    required this.mealType,
    required this.startMinutes,
    required this.index,
  });

  final String mealType;
  final int startMinutes;
  final int index;
}