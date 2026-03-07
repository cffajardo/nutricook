import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:nutricook/features/home/widgets/home_category_row.dart';
import 'package:nutricook/features/home/widgets/home_meal_overview_card.dart';
import 'package:nutricook/features/home/widgets/home_search_bar.dart';
import 'package:nutricook/features/home/widgets/home_trending_carousel.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const List<String> _categories = <String>[
    'Cuisine',
    'Dietary',
    'Nutrition',
    'Difficulty',
  ];

  final PageController _trendingPageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _clockTimer;

  int _selectedNavIndex = 2;
  int _currentTrendingPage = 0;
  String _selectedCategory = _categories.first;
  bool _showFollowing = false;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Keep meal timeframe aligned with device time.
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  String get _autoMealType {
    final hour = _now.hour;
    if (hour < 11) return 'Breakfast';
    if (hour < 16) return 'Lunch';
    if (hour < 22) return 'Dinner';
    return 'Snack';
  }

  DateTime get _selectedDate => DateTime(_now.year, _now.month, _now.day);

  @override
  void dispose() {
    _clockTimer?.cancel();
    _trendingPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trendingRecipesAsync = ref.watch(trendingRecipesProvider);
    final plannerItemsAsync = ref.watch(
      plannerItemsForDateProvider(_selectedDate),
    );
    final breakfastItems = ref.watch(
      plannerItemsByMealTypeProvider((
        date: _selectedDate,
        mealType: _autoMealType,
      )),
    );
    final dailyTotalsAsync = ref.watch(
      dailyNutritionTotalProvider(_selectedDate),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.authBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Home Screen',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                HomeSearchBar(
                  controller: _searchController,
                  onProfileTap: () {},
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showFollowing = false;
                        });
                      },
                      child: Text(
                        'Trending',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: _showFollowing
                              ? Colors.black.withValues(alpha: 0.55)
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showFollowing = true;
                        });
                      },
                      child: Text(
                        'Following',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _showFollowing
                              ? Colors.black87
                              : Colors.black.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
                _showFollowing
                    ? const _FollowingBlankCard()
                    : HomeTrendingCarousel(
                        recipesAsync: trendingRecipesAsync,
                        pageController: _trendingPageController,
                        currentIndex: _currentTrendingPage,
                        onPageChanged: (index) {
                          setState(() {
                            _currentTrendingPage = index;
                          });
                        },
                      ),
                const SizedBox(height: 14),
                HomeCategoryRow(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                plannerItemsAsync.when(
                  loading: () => const _PlannerLoadingCard(),
                  error: (_, __) => const _PlannerErrorCard(),
                  data: (_) => HomeMealOverviewCard(
                    date: _selectedDate,
                    mealType: _autoMealType,
                    items: breakfastItems,
                    totals: dailyTotalsAsync.value,
                    isTotalsLoading: dailyTotalsAsync.isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }
}

class _PlannerLoadingCard extends StatelessWidget {
  const _PlannerLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.rosePink),
      ),
    );
  }
}

class _PlannerErrorCard extends StatelessWidget {
  const _PlannerErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Text(
          'Could not load planner items.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FollowingBlankCard extends StatelessWidget {
  const _FollowingBlankCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardRose,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }
}
