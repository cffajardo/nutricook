import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';

class PlannerDatePickModal extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const PlannerDatePickModal({super.key, required this.initialDate});

  @override
  ConsumerState<PlannerDatePickModal> createState() => _PlannerDatePickModalState();
}

class _PlannerDatePickModalState extends ConsumerState<PlannerDatePickModal> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final dayItemsAsync = ref.watch(plannerItemsForDateProvider(_selectedDate));

    return Container(
      height: MediaQuery.of(context).size.height * 0.95, 
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10))),
              
              _buildHeader(),
              const Divider(height: 1),

              _buildCalendarSection(),

              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, size: 18, color: AppColors.rosePink),
                    const SizedBox(width: 8),
                    Text(
                      'Meals for ${DateFormat('MMM d').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: dayItemsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Failed to load planned meals: $error'),
                    ),
                  ),
                  data: _buildDailyRecipeList,
                ),
              ),
            ],
          ),

          Positioned(
            right: 24,
            bottom: 30,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context, _selectedDate),
              backgroundColor: AppColors.rosePink,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: AppColors.rosePink, size: 30),
          ),
          const Text('Plan date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedDate),
            child: const Text('Save', style: TextStyle(color: AppColors.rosePink, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMMM yyyy').format(_focusedDate), 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.rosePink)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          _focusedDate.month - 1,
                          1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_left, color: AppColors.rosePink),
                  ),
                  TextButton(
                    onPressed: () {
                      final now = DateTime.now();
                      setState(() {
                        _focusedDate = DateTime(now.year, now.month, 1);
                        _selectedDate = DateTime(now.year, now.month, now.day);
                      });
                    },
                    child: const Text(
                      'Today',
                      style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          _focusedDate.month + 1,
                          1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_right, color: AppColors.rosePink),
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(
          height: 300, 
          child: CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2024),
            lastDate: DateTime(2030),
            currentDate: _selectedDate,
            onDisplayedMonthChanged: (month) {
              setState(() {
                _focusedDate = DateTime(month.year, month.month, 1);
              });
            },
            onDateChanged: (date) => setState(() {
              _selectedDate = date;
              _focusedDate = DateTime(date.year, date.month, 1);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyRecipeList(List<PlannerItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No planned meals for this date.',
          style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final calories = ((item.nutritionPerServing?.calories ?? 0) * item.servingMultiplier).round();

        return Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.cardRose,
            border: Border.all(
              color: AppColors.rosePink.withValues(alpha: 0.15),
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.rosePink.withValues(alpha: 0.9),
                        AppColors.rosePink.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.recipeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.mealType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$calories Cal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
        );
      },
    );
  }
}