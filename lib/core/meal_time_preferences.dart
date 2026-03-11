const List<String> orderedMealTypes = <String>[
  'Breakfast',
  'Lunch',
  'Snack',
  'Dinner',
  'Other',
];

const Map<String, int> defaultMealStartHours = <String, int>{
  'Breakfast': 5,
  'Lunch': 11,
  'Snack': 15,
  'Dinner': 18,
  'Other': 22,
};

Map<String, int> sanitizeMealStartHours(Map<String, int>? hours) {
  return <String, int>{
    for (final mealType in orderedMealTypes)
      mealType: (hours?[mealType] ?? defaultMealStartHours[mealType]!)
          .clamp(0, 23)
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

String formatMealHourLabel(int hour) {
  final normalized = hour.clamp(0, 23);
  final displayHour = normalized % 12 == 0 ? 12 : normalized % 12;
  final suffix = normalized < 12 ? 'AM' : 'PM';
  return '$displayHour:00 $suffix';
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