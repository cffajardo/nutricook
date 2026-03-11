import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';

class HomeMealOverviewCard extends StatelessWidget {
  const HomeMealOverviewCard({
    super.key,
    required this.date,
    required this.mealType,
    required this.items,
    required this.totals,
    required this.isTotalsLoading,
  });

  final DateTime date;
  final String mealType;
  final List<PlannerItem> items;
  final NutritionInfo? totals;
  final bool isTotalsLoading;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, MMM d').format(date);
    final previewItems = items.take(3).toList(growable: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.14),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final snug = constraints.maxWidth < 420;

          return snug
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMealInfo(dateLabel, previewItems),
                    const SizedBox(height: 12),
                    _buildTotalsBox(expand: true),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMealInfo(dateLabel, previewItems)),
                    const SizedBox(width: 12),
                    SizedBox(width: 130, child: _buildTotalsBox()),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildMealInfo(String dateLabel, List<PlannerItem> previewItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 0.9,
            color: AppColors.rosePink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mealType,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 110),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardRose,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.rosePink.withValues(alpha: 0.1),
              width: 1.2,
            ),
          ),
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No recipes planned yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                )
              : Column(
                  children: [
                    ...previewItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: AppColors.rosePink,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.recipeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (items.length > previewItems.length)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+${items.length - previewItems.length} more',
                          style: const TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTotalsBox({bool expand = false}) {
    return Container(
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardRose,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Totals',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
              color: AppColors.rosePink,
            ),
          ),
          const SizedBox(height: 12),
          if (isTotalsLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.rosePink,
                ),
              ),
            )
          else ...[
            _MetricRow(
              label: 'Cals',
              value: totals?.calories.toString() ?? '-',
            ),
            _MetricRow(
              label: 'Prot',
              value: '${totals?.protein.round() ?? 0}g',
            ),
            _MetricRow(label: 'Fats', value: '${totals?.fat.round() ?? 0}g'),
            _MetricRow(
              label: 'Carbs',
              value: '${totals?.carbohydrates.round() ?? 0}g',
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
