import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:nutricook/features/planner/widgets/planner_nutrition_total_modal.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/features/planner/widgets/planner_item_modal_screen.dart';
import 'package:nutricook/routing/app_routes.dart';

class PlannerHistoryScreen extends ConsumerStatefulWidget {
  const PlannerHistoryScreen({super.key});

  @override
  ConsumerState<PlannerHistoryScreen> createState() => _PlannerHistoryScreenState();
}

class _PlannerHistoryScreenState extends ConsumerState<PlannerHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  final double _dateItemWidth = 70.0;
  late List<DateTime> _dateList = _getDatesForMonth(_currentMonth);
  late final ScrollController _dateScrollController;

  @override
  void initState() {
    super.initState();
    _dateScrollController = ScrollController(
      initialScrollOffset: _calculateDateOffset(_selectedDate),
    );
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  List<DateTime> _getDatesForMonth(DateTime month) {
    final int days = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(days, (i) => DateTime(month.year, month.month, i + 1));
  }

  double _calculateDateOffset(DateTime date) {
    final int index = _dateList.indexWhere(
      (d) => d.day == date.day && d.month == date.month,
    );
    return index != -1 ? index * _dateItemWidth : 0.0;
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
        1,
      );
      _dateList = _getDatesForMonth(_currentMonth);
      _selectedDate = _dateList.first;
    });
    _dateScrollController.jumpTo(0);
  }

  void _snapToDate(int index) {
    if (_dateScrollController.hasClients) {
      _dateScrollController.animateTo(
        index * _dateItemWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        title: const Text('Planner History', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMonthlySummaryHeader(),
          const SizedBox(height: 16),
          _buildDateSelector(),
          const SizedBox(height: 20),
          Expanded(child: _buildHistoryContent()),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryHeader() {
    final monthlyNutrition = ref.watch(monthlyNutritionTotalProvider(_currentMonth));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.rosePink.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: () => _changeMonth(-1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            monthlyNutrition.when(
              data: (nutrition) {
                final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
                final avgCalories = nutrition.calories / daysInMonth;
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Calories', '${nutrition.calories.round()}', 'kcal'),
                        _buildSummaryItem('Protein', '${nutrition.protein.round()}', 'g'),
                        _buildSummaryItem('Carbs', '${nutrition.carbohydrates.round()}', 'g'),
                        _buildSummaryItem('Fat', '${nutrition.fat.round()}', 'g'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.rosePink.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt_rounded, size: 16, color: AppColors.rosePink),
                          const SizedBox(width: 8),
                          Text(
                            'Average Daily Calories: ',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black.withValues(alpha: 0.6)),
                          ),
                          Text(
                            '${avgCalories.round()} kcal',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.rosePink),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.rosePink)),
        Text(unit, style: const TextStyle(fontSize: 10, color: Colors.black26)),
      ],
    );
  }

  Widget _buildDateSelector() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = (screenWidth / 2) - (_dateItemWidth / 2);

    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: padding),
        itemCount: _dateList.length,
        itemExtent: _dateItemWidth,
        itemBuilder: (context, index) {
          final date = _dateList[index];
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isFuture = date.isAfter(DateTime.now());

          return GestureDetector(
            onTap: isFuture ? null : () {
              setState(() => _selectedDate = date);
              _snapToDate(index);
            },
            child: Opacity(
              opacity: isFuture ? 0.3 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.cardRose.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.rosePink : AppColors.rosePink.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? AppColors.rosePink : Colors.black26,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: isSelected ? 22 : 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.black87 : Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryContent() {
    final itemsAsync = ref.watch(plannerItemsForDateProvider(_selectedDate));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 48, color: Colors.black12),
                SizedBox(height: 16),
                Text('No meal plans found for this date.', 
                  style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        final dailyNutrition = ref.watch(dailyNutritionTotalProvider(_selectedDate));

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _buildDailyNutritionCard(dailyNutrition),
            const SizedBox(height: 24),
            const Text('Meals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...items.map((item) => _buildHistoryMealCard(item)),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildDailyNutritionCard(AsyncValue<dynamic> nutritionAsync) {
    return nutritionAsync.when(
      data: (nutrition) => Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Daily Nutrition', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDailyStat('Calories', '${nutrition.calories.round()}', 'kcal'),
                _buildDailyStat('Protein', '${nutrition.protein.round()}', 'g'),
                _buildDailyStat('Carbs', '${nutrition.carbohydrates.round()}', 'g'),
                _buildDailyStat('Fat', '${nutrition.fat.round()}', 'g'),
              ],
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildDailyStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(unit, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildHistoryMealCard(PlannerItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cardRose.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.rosePink, size: 20),
        ),
        title: Text(item.recipeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text('${item.mealType} • ${item.servingMultiplier}x serving', style: const TextStyle(fontSize: 12, color: Colors.black45)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.rosePink.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${((item.nutritionPerServing?.calories ?? 0) * item.servingMultiplier).round()} cal',
            style: const TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => PlannerItemModal(item: item),
          );
        },
      ),
    );
  }
}
