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
      startMinutes: sanitized[entry.value]! * 60,
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