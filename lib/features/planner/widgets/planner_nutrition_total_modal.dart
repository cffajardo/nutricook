import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:nutricook/features/planner/util/nutrition_info_util.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';

class PlannerNutritionTotalsModal extends ConsumerWidget {
  final DateTime selectedDate;
  final List<String> mealTypes;

  const PlannerNutritionTotalsModal({
    super.key,
    required this.selectedDate,
    required this.mealTypes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(plannerItemsForDateProvider(selectedDate));
    final dailyAsync = ref.watch(dailyNutritionTotalProvider(selectedDate));
    final preferences = ref.watch(userPreferencesProvider).asData?.value;
    final dailyCalorieGoal = preferences?.dailyCalorieGoal ?? 2000;

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
          const Text(
            'Daily Nutrition',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(
            'Totals for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          dailyAsync.when(
            loading: () => _buildUnifiedHero(
              const NutritionInfo(
                calories: 0,
                carbohydrates: 0,
                protein: 0,
                fat: 0,
                fiber: 0,
                sugar: 0,
                sodium: 0,
              ),
            ),
            error: (error, stackTrace) => _buildUnifiedHero(
              const NutritionInfo(
                calories: 0,
                carbohydrates: 0,
                protein: 0,
                fat: 0,
                fiber: 0,
                sugar: 0,
                sodium: 0,
              ),
            ),
            data: _buildUnifiedHero,
          ),
          const SizedBox(height: 14),
          dailyAsync.when(
            loading: () => _buildGoalStatus(
              totalCalories: 0,
              dailyCalorieGoal: dailyCalorieGoal,
              isLoading: true,
            ),
            error: (_, _) => _buildGoalStatus(
              totalCalories: 0,
              dailyCalorieGoal: dailyCalorieGoal,
              hasError: true,
            ),
            data: (nutrition) => _buildGoalStatus(
              totalCalories: nutrition.calories,
              dailyCalorieGoal: dailyCalorieGoal,
            ),
          ),

          const SizedBox(height: 32),
          const Text(
            'Meal Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Failed to load data: $error')),
              data: (items) => ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: mealTypes.length,
                itemBuilder: (context, index) {
                  final meal = mealTypes[index];
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
    bool isLoading = false,
    bool hasError = false,
  }) {
    final delta = totalCalories - dailyCalorieGoal;
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
        ? 'Checking daily goal...'
        : isOnTarget
        ? 'On goal: $dailyCalorieGoal kcal'
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
            '$totalCalories / $dailyCalorieGoal kcal',
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
            '$calories kcal',
            style: const TextStyle(
              color: AppColors.rosePink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
        ],
      ),
    );
  }
}
