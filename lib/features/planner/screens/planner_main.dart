import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/meal_time_preferences.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/features/planner/widgets/planner_item_modal_screen.dart';
import 'package:nutricook/features/planner/widgets/planner_item_edit_modal.dart';
import 'package:nutricook/features/planner/widgets/planner_nutrition_total_modal.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/routing/app_routes.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  Timer? _clockTimer;
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String _selectedMeal = 'Breakfast';
  bool _didInitializeAutoMeal = false;

  final List<String> _mealTypes = orderedMealTypes;
  final double _dateItemWidth = 70.0;

  late List<DateTime> _dateList = _getDatesForMonth(_currentMonth);

  late final ScrollController _dateScrollController;

  late final PageController _mealPageController;

  List<DateTime> _getDatesForMonth(DateTime month) {
    final int days = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(days, (i) => DateTime(month.year, month.month, i + 1));
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize the current meal based on time settings (only if today's date)
    if (isSameCalendarDay(_selectedDate, DateTime.now())) {
      final mealStartHours = ref.read(mealStartHoursProvider);
      final currentMeal = resolveMealTypeForTime(DateTime.now(), mealStartHours);
      final index = _mealTypes.indexOf(currentMeal);
      
      if (index != -1) {
        _selectedMeal = currentMeal;
        _didInitializeAutoMeal = true;
      }
    }
    
    _dateScrollController = ScrollController(
      initialScrollOffset: _calculateDateOffset(_selectedDate),
    );
    
    _mealPageController = PageController(
      viewportFraction: 0.45,
      initialPage: _mealTypes.indexOf(_selectedMeal),
    );
    
    // Set up periodic sync for auto meal selection
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final mealStartHours = ref.read(mealStartHoursProvider);
      _syncAutoMealSelection(mealStartHours);
    });
  }

  double _calculateDateOffset(DateTime date) {
    final int index = _dateList.indexWhere(
      (d) => d.day == date.day && d.month == date.month,
    );
    return index != -1 ? index * _dateItemWidth : 0.0;
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _dateScrollController.dispose();
    _mealPageController.dispose();
    super.dispose();
  }

  void _syncAutoMealSelection(
    Map<String, int> mealStartHours, {
    bool animate = true,
  }) {
    if (!isSameCalendarDay(_selectedDate, DateTime.now())) {
      return;
    }

    final autoMeal = resolveMealTypeForTime(DateTime.now(), mealStartHours);
    if (autoMeal == _selectedMeal) {
      return;
    }

    final index = _mealTypes.indexOf(autoMeal);
    if (index == -1) {
      return;
    }

    setState(() => _selectedMeal = autoMeal);

    if (_mealPageController.hasClients) {
      if (animate) {
        _mealPageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        _mealPageController.jumpToPage(index);
      }
    }
  }

  void _snapToDate(int index) {
    if (_dateScrollController.hasClients &&
        (_dateScrollController.offset - (index * _dateItemWidth)).abs() > 1.0) {
      _dateScrollController.animateTo(
        index * _dateItemWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _changeMonth(int offset, Map<String, int> mealStartHours) {
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
    _syncAutoMealSelection(mealStartHours, animate: false);
  }

  @override
  Widget build(BuildContext context) {
    final mealStartHours = ref.watch(mealStartHoursProvider);
    final preferences = ref.watch(userPreferencesProvider).asData?.value;

    if (!_didInitializeAutoMeal && preferences != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _didInitializeAutoMeal) return;
        _didInitializeAutoMeal = true;
        _syncAutoMealSelection(mealStartHours, animate: false);
      });
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFF9FA),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildHeader(mealStartHours),
                const SizedBox(height: 16),
                _buildDateCarousel(mealStartHours),
                const SizedBox(height: 20),
                _buildMealCarousel(),
                const SizedBox(height: 16),
                Expanded(child: _buildRecipeList()),
              ],
            ),
          ),

          _buildFab(left: 24, icon: Icons.pie_chart_rounded, tag: 'fab_n'),
          _buildFab(right: 24, icon: Icons.add_rounded, tag: 'fab_m'),
        ],
      ),
    );
  }

  Widget _buildFab({
    double? left,
    double? right,
    required IconData icon,
    required String tag,
  }) {
    return Positioned(
      left: left,
      right: right,
      bottom: 13,
      child: FloatingActionButton(
        heroTag: tag,
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.rosePink, width: 1.5),
        ),
        onPressed: () {
          if (tag == 'fab_n') {
            _showNutritionMenu();
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PlannerItemEditModal(
                initialDate: _selectedDate,
                initialMealType: _selectedMeal,
              ),
            );
          }
        },
        child: Icon(icon, color: AppColors.rosePink, size: 22),
      ),
    );
  }

  Widget _buildHeader(Map<String, int> mealStartHours) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Planner',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rosePink,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.rosePink),
                onPressed: () => _changeMonth(-1, mealStartHours),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.rosePink,
                ),
                onPressed: () => _changeMonth(1, mealStartHours),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateCarousel(Map<String, int> mealStartHours) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = (screenWidth / 2) - (_dateItemWidth / 2);

    return SizedBox(
      height: 100,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            final index = (_dateScrollController.offset / _dateItemWidth)
                .round();
            if (index >= 0 && index < _dateList.length) {
              final newDate = _dateList[index];
              // Only trigger setState if the day has actually changed
              if (newDate.day != _selectedDate.day ||
                  newDate.month != _selectedDate.month) {
                HapticFeedback.lightImpact();
                setState(() => _selectedDate = newDate);
                _syncAutoMealSelection(mealStartHours);
              }
              _snapToDate(index);
            }
          }
          return true;
        },
        child: ListView.builder(
          controller: _dateScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: padding),
          itemCount: _dateList.length,
          itemExtent: _dateItemWidth,
          itemBuilder: (context, index) {
            final date = _dateList[index];
            final isSelected =
                date.day == _selectedDate.day &&
                date.month == _selectedDate.month;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
                _syncAutoMealSelection(mealStartHours);
                _snapToDate(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : AppColors.cardRose.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.rosePink
                        : AppColors.rosePink.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.rosePink.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? AppColors.rosePink : Colors.black26,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: isSelected ? 24 : 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.black87 : Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMealCarousel() {
    return SizedBox(
      height: 60,
      child: PageView.builder(
        controller: _mealPageController,
        onPageChanged: (index) =>
            setState(() => _selectedMeal = _mealTypes[index]),
        itemCount: _mealTypes.length,
        itemBuilder: (context, index) {
          final isSelected = _mealTypes[index] == _selectedMeal;
          return GestureDetector(
            onTap: () {
              _mealPageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            },
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 32 : 22,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? AppColors.rosePink : Colors.black26,
                ),
                child: Text(_mealTypes[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeList() {
    final itemsAsync = ref.watch(plannerItemsForDateProvider(_selectedDate));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load planner items: $error'),
        ),
      ),
      data: (items) {
        final filtered = items
            .where((item) => item.mealType == _selectedMeal)
            .toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text('No planned recipes for this meal yet.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 180),
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            return _buildPlannerCard(item);
          },
        );
      },
    );
  }

  Widget _buildPlannerCard(PlannerItem item) {
    final calories =
        ((item.nutritionPerServing?.calories ?? 0) * item.servingMultiplier)
            .round();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PlannerItemModal(item: item),
        );
      },
      child: Container(
        height: 180,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.rosePink.withValues(alpha: 0.14),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.rosePink.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.white)),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.rosePink.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
              if (item.isCompleted)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green, width: 1.2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.recipeName,
                      style: TextStyle(
                        color: item.isCompleted
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Servings: ${item.servingMultiplier}x',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$calories Cal',
                            style: const TextStyle(
                              color: AppColors.rosePink,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNutritionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nutrition & History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.pie_chart_rounded,
              title: 'Daily Nutrition',
              subtitle: 'View detailed totals for today',
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PlannerNutritionTotalsModal(
                    selectedDate: _selectedDate,
                    mealTypes: _mealTypes,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.history_rounded,
              title: 'Planner History',
              subtitle: 'Past plans and monthly trends',
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(AppRoutes.plannerHistoryName);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardRose.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.rosePink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
