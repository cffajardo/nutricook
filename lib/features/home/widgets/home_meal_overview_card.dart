import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/nutrition_info/nutrition_info.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';

class HomeMealOverviewCard extends StatefulWidget {
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
  State<HomeMealOverviewCard> createState() => _HomeMealOverviewCardState();
}

class _HomeMealOverviewCardState extends State<HomeMealOverviewCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, MMM d').format(widget.date);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.14),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.rosePink.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(dateLabel),
          const SizedBox(height: 20),
          _buildRecipeCarousel(),
          const SizedBox(height: 12),
          _buildCarouselIndicator(),
        ],
      ),
    );
  }

  Widget _buildHeader(String dateLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.black38,
                ),
              ),
              Text(
                widget.mealType,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        _buildCalorieBadge(),
      ],
    );
  }

  Widget _buildCalorieBadge() {
    // Calculate meal time total calories
    int mealCalories = 0;
    for (final item in widget.items) {
      final n = item.nutritionPerServing;
      if (n != null) {
        final scale = (item.servingMultiplier is num) ? (item.servingMultiplier as num).toDouble() : 1.0;
        final double calories = (n.calories is num) ? (n.calories as num).toDouble() : 0.0;
        mealCalories += (calories * scale).round();
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.rosePink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: widget.isTotalsLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Column(
              children: [
                Text(
                  mealCalories.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const Text(
                  'KCAL',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRecipeCarousel() {
    if (widget.items.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardRose.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.05), width: 1.5),
        ),
        child: const Center(
          child: Text(
            'No recipes planned',
            style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardRose.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.rosePink.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: item.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.rosePink.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.rosePink.withValues(alpha: 0.3),
                                size: 24,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            color: AppColors.rosePink.withValues(alpha: 0.4),
                            size: 32,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECIPE ${index + 1}',
                        style: const TextStyle(
                          color: AppColors.rosePink,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        item.recipeName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarouselIndicator() {
    if (widget.items.length <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.rosePink : Colors.black12,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}