import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:nutricook/features/planner/util/nutrition_info_util.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';

class PlannerNutritionTotalsModal extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final List<String> mealTypes;

  const PlannerNutritionTotalsModal({
    super.key,
    required this.selectedDate,
    required this.mealTypes,
  });

  @override
  ConsumerState<PlannerNutritionTotalsModal> createState() =>
      _PlannerNutritionTotalsModalState();
}

class _PlannerNutritionTotalsModalState
    extends ConsumerState<PlannerNutritionTotalsModal> {
  int _viewMode = 0; // 0: Day, 1: Week, 2: Month

  @override
  Widget build(BuildContext context) {
    final itemsAsync = _viewMode == 0
        ? ref.watch(plannerItemsForDateProvider(widget.selectedDate))
        : _viewMode == 1
        ? ref.watch(plannerItemsForWeekProvider(widget.selectedDate))
        : ref.watch(plannerItemsForMonthProvider(widget.selectedDate));
    final nutritionAsync = _viewMode == 0
        ? ref.watch(dailyNutritionTotalProvider(widget.selectedDate))
        : _viewMode == 1
        ? ref.watch(weeklyNutritionTotalProvider(widget.selectedDate))
        : ref.watch(monthlyNutritionTotalProvider(widget.selectedDate));

    final preferences = ref.watch(userPreferencesProvider).asData?.value;
    final dailyCalorieGoal = preferences?.dailyCalorieGoal ?? 2000;
    final daysInMonth = DateUtils.getDaysInMonth(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );

    final weekStart = widget.selectedDate.subtract(
      Duration(days: widget.selectedDate.weekday - 1),
    );
    final daysInWeek = 7;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _viewMode == 0
                ? 'Daily Nutrition'
                : _viewMode == 1
                ? 'Weekly Nutrition'
                : 'Monthly Nutrition',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(
            _viewMode == 0
                ? 'Totals for ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}'
                : _viewMode == 1
                ? 'Totals for week starting ${weekStart.day}/${weekStart.month}/${weekStart.year}'
                : 'Totals for ${widget.selectedDate.month}/${widget.selectedDate.year}',
            style: const TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(value: 0, label: Text('Day')),
                ButtonSegment<int>(value: 1, label: Text('Week')),
                ButtonSegment<int>(value: 2, label: Text('Month')),
              ],
              selected: <int>{_viewMode},
              onSelectionChanged: (selection) {
                setState(() {
                  _viewMode = selection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          nutritionAsync.when(
            loading: () => _buildUnifiedHero(_emptyNutrition),
            error: (_, _) => _buildUnifiedHero(_emptyNutrition),
            data: _buildUnifiedHero,
          ),
          const SizedBox(height: 14),
          nutritionAsync.when(
            loading: () => _buildGoalStatus(
              totalCalories: 0,
              dailyCalorieGoal: dailyCalorieGoal,
              viewMode: _viewMode,
              monthDayCount: daysInMonth,
              weekDayCount: daysInWeek,
              isLoading: true,
            ),
            error: (_, _) => _buildGoalStatus(
              totalCalories: 0,
              dailyCalorieGoal: dailyCalorieGoal,
              viewMode: _viewMode,
              monthDayCount: daysInMonth,
              weekDayCount: daysInWeek,
              hasError: true,
            ),
            data: (nutrition) => _buildGoalStatus(
              totalCalories: nutrition.calories,
              dailyCalorieGoal: dailyCalorieGoal,
              viewMode: _viewMode,
              monthDayCount: daysInMonth,
              weekDayCount: daysInWeek,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _viewMode == 0
                ? 'Meal Breakdown'
                : _viewMode == 1
                ? 'Weekly Meal Breakdown'
                : 'Monthly Meal Breakdown',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Failed to load data: $error')),
              data: (items) => ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.mealTypes.length,
                itemBuilder: (context, index) {
                  final meal = widget.mealTypes[index];
                  final mealItems = items
                      .where((item) => item.mealType == meal)
                      .toList();
                  final mealNutrition = calculatePlannerNutrition(
                    plannerItems: mealItems,
                  );
                  return _buildMealRow(meal, mealNutrition.calories);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  NutritionInfo get _emptyNutrition => const NutritionInfo(
    calories: 0,
    carbohydrates: 0,
    protein: 0,
    fat: 0,
    fiber: 0,
    sugar: 0,
    sodium: 0,
  );

  Widget _buildUnifiedHero(NutritionInfo nutrition) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.rosePink,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.rosePink.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeroStat('Calories', '${nutrition.calories}', 'kcal'),
            _buildDivider(),
            _buildHeroStat(
              'Protein',
              nutrition.protein.toStringAsFixed(1),
              'g',
            ),
            _buildDivider(),
            _buildHeroStat(
              'Carbs',
              nutrition.carbohydrates.toStringAsFixed(1),
              'g',
            ),
            _buildDivider(),
            _buildHeroStat('Fat', nutrition.fat.toStringAsFixed(1), 'g'),
            _buildDivider(),
            _buildHeroStat('Fiber', nutrition.fiber.toStringAsFixed(1), 'g'),
            _buildDivider(),
            _buildHeroStat('Sugars', nutrition.sugar.toStringAsFixed(1), 'g'),
            _buildDivider(),
            _buildHeroStat(
              'Sodium',
              (nutrition.sodium / 1000).toStringAsFixed(1),
              'g',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStatus({
    required int totalCalories,
    required int dailyCalorieGoal,
    required int viewMode, // 0: Day, 1: Week, 2: Month
    required int monthDayCount,
    required int weekDayCount,
    bool isLoading = false,
    bool hasError = false,
  }) {
    final targetCalories = viewMode == 0
        ? dailyCalorieGoal
        : viewMode == 1
        ? dailyCalorieGoal * weekDayCount
        : dailyCalorieGoal * monthDayCount;
    final delta = totalCalories - targetCalories;
    final isOver = delta > 0;
    final isOnTarget = delta == 0;

    final statusColor = hasError
        ? Colors.redAccent
        : isLoading
        ? Colors.blueGrey
        : isOnTarget
        ? Colors.green
        : isOver
        ? Colors.redAccent
        : AppColors.rosePink;

    final statusText = hasError
        ? 'Goal status unavailable'
        : isLoading
        ? (viewMode == 0
              ? 'Checking daily goal...'
              : viewMode == 1
              ? 'Checking weekly goal...'
              : 'Checking monthly goal...')
        : isOnTarget
        ? 'On goal: $targetCalories kcal'
        : isOver
        ? 'Over by ${delta.abs()} kcal'
        : '${delta.abs()} kcal remaining';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
          Text(
            '$totalCalories / $targetCalories kcal',
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 35, color: Colors.white24);

  Widget _buildMealRow(String meal, int calories) {
    final label = _viewMode == 2 ? '$calories kcal total' : '$calories kcal';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            meal,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.rosePink,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
        ],
      ),
    );
  }
}
