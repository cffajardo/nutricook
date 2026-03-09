import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:nutricook/features/planner/widgets/planner_item_modal_screen.dart';
import 'package:nutricook/features/planner/widgets/planner_item_edit_modal.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String _selectedMeal = 'Breakfast';

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Snack', 'Dinner', 'Other'];
  final double _dateItemWidth = 70.0; 

  late List<DateTime> _dateList = _getDatesForMonth(_currentMonth);

  late ScrollController _dateScrollController = ScrollController(
    initialScrollOffset: _calculateDateOffset(_selectedDate),
  );

  late PageController _mealPageController = PageController(
    viewportFraction: 0.45,
    initialPage: _mealTypes.indexOf(_selectedMeal),
  );

  List<DateTime> _getDatesForMonth(DateTime month) {
    final int days = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(days, (i) => DateTime(month.year, month.month, i + 1));
  }

  double _calculateDateOffset(DateTime date) {
    final int index = _dateList.indexWhere((d) => 
        d.day == date.day && d.month == date.month);
    return index != -1 ? index * _dateItemWidth : 0.0;
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    _mealPageController.dispose();
    super.dispose();
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

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
      _dateList = _getDatesForMonth(_currentMonth);
      _selectedDate = _dateList.first;
    });
    _dateScrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
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
                _buildHeader(),
                const SizedBox(height: 16),
                _buildDateCarousel(),
                const SizedBox(height: 20),
                _buildMealCarousel(),
                const SizedBox(height: 16),
                Expanded(child: _buildRecipeList()),
              ],
            ),
          ),

          _buildFab(left: 24, label: 'N', tag: 'fab_n'),
          _buildFab(right: 24, label: 'M', tag: 'fab_m'),

          const Positioned(
            left: 0, right: 0, bottom: 0,
            child: CustomBottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFab({double? left, double? right, required String label, required String tag}) {
    return Positioned(
      left: left, right: right, bottom: 120,
      child: FloatingActionButton(
        heroTag: tag,
        backgroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        onPressed: () {
           showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const PlannerItemEditModal(),
          );
        },
        child: Text(label, style: const TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Planner', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.black87)),
              Text(DateFormat('MMMM yyyy').format(_currentMonth),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.rosePink)),
            ],
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, color: AppColors.rosePink), onPressed: () => _changeMonth(-1)),
              IconButton(icon: const Icon(Icons.chevron_right, color: AppColors.rosePink), onPressed: () => _changeMonth(1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDateCarousel() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = (screenWidth / 2) - (_dateItemWidth / 2);

    return SizedBox(
      height: 100,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            final index = (_dateScrollController.offset / _dateItemWidth).round();
            if (index >= 0 && index < _dateList.length) {
              final newDate = _dateList[index];
              // Only trigger setState if the day has actually changed
              if (newDate.day != _selectedDate.day || newDate.month != _selectedDate.month) {
                HapticFeedback.lightImpact(); 
                setState(() => _selectedDate = newDate);
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
            final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
                _snapToDate(index);
              },
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
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.rosePink.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
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
        onPageChanged: (index) => setState(() => _selectedMeal = _mealTypes[index]),
        itemCount: _mealTypes.length,
        itemBuilder: (context, index) {
          final isSelected = _mealTypes[index] == _selectedMeal;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 32 : 22,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? AppColors.rosePink : Colors.black26,
              ),
              child: Text(_mealTypes[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeList() {
    return ListView.builder(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 180),
    physics: const BouncingScrollPhysics(),
    itemCount: 4, 
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PlannerItemModal(recipe: {'name': 'Recipe $index'}), 
          );
        },
        child: Container(
          height: 180, 
          width: double.infinity, 
          margin: const EdgeInsets.only(bottom: 20), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.14), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.rosePink.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
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
                        colors: [Colors.transparent, AppColors.rosePink.withValues(alpha: 0.85)],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delicious Recipe $index', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Servings: 2', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: const Text('350 Cal', style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}