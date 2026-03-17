import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/meal_time_preferences.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/home/widgets/home_category_row.dart';
import 'package:nutricook/features/home/widgets/home_meal_overview_card.dart';
import 'package:nutricook/features/home/widgets/home_trending_carousel.dart';
import 'package:nutricook/features/home/widgets/home_search_bar.dart';
import 'package:nutricook/features/notifications/provider/notification_provider.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/routing/navigation_provider.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final PageController _pageController = PageController(viewportFraction: 1.0);
  final TextEditingController _searchController = TextEditingController();

  Timer? _clockTimer;
  bool _showFollowing = false;
  int _currentPage = 0;
  String _selectedCategory = _categories.first;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  DateTime get _selectedDate => DateTime(_now.year, _now.month, _now.day);

  void _submitHomeSearch(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    context.pushNamed(
      AppRoutes.homeUserSearchName,
      queryParameters: {'q': query},
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(activeTabProvider, (previous, next) {
      if (previous != next) {
        _searchController.clear();
      }
    });

    final mealStartHours = ref.watch(mealStartHoursProvider);
    final autoMealType = resolveMealTypeForTime(
      _now,
      mealStartHours,
    );
    final trendingAsync = ref.watch(visibleTrendingRecipesProvider);
    final followingAsync = ref.watch(followingRecipesProvider);
    final mealItems = ref.watch(
      plannerItemsByMealTypeProvider((
        date: _selectedDate,
        mealType: autoMealType,
      )),
    );
    final dailyTotalsAsync = ref.watch(
      dailyNutritionTotalProvider(_selectedDate),
    );
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).asData?.value ?? 0;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFFF9FA),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  HomeSearchBar(
                    controller: _searchController,
                    unreadCount: unreadCount,
                    onSubmitted: _submitHomeSearch,
                    onNotificationTap: () {
                      context.pushNamed(AppRoutes.notificationsName);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTabs(),
                  const SizedBox(height: 16),

                  _showFollowing
                      ? HomeTrendingCarousel(
                          recipesAsync: followingAsync,
                          pageController: _pageController,
                          currentIndex: _currentPage,
                          emptyMessage: 'Follow users to see their recipes',
                          onPageChanged: (index) {
                            if (!mounted) return;
                            setState(() => _currentPage = index);
                          },
                        )
                      : HomeTrendingCarousel(
                          recipesAsync: trendingAsync,
                          pageController: _pageController,
                          currentIndex: _currentPage,
                          onPageChanged: (index) {
                            if (!mounted) return;
                            setState(() => _currentPage = index);
                          },
                        ),

                  const SizedBox(height: 24),

                  const Text(
                    'Discover Recipes',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.rosePink,
                    ),
                  ),

                  const SizedBox(height: 12),
                  HomeCategoryRow(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (val) {
                      setState(() => _selectedCategory = val);
                      context.goNamed(
                        AppRoutes.subCategoryName,
                        pathParameters: {'category': val},
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  HomeMealOverviewCard(
                    date: _selectedDate,
                    mealType: autoMealType,
                    items: mealItems,
                    totals: dailyTotalsAsync.asData?.value,
                    isTotalsLoading: dailyTotalsAsync.isLoading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final colorScheme = Theme.of(context).colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width - 32;
    return SizedBox(
      height: 60,
      width: screenWidth,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            left: _showFollowing ? screenWidth * 0.5 : 0,
            bottom: _showFollowing ? 12 : 4,
            child: InkWell(
              onTap: () {
                setState(() => _showFollowing = false);
                _pageController.jumpToPage(0);
                _currentPage = 0;
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                style: TextStyle(
                  fontSize: _showFollowing ? 22 : 36,
                  fontWeight: _showFollowing
                      ? FontWeight.bold
                      : FontWeight.w900,
                  color: _showFollowing
                      ? colorScheme.onSurface.withValues(alpha: 0.5)
                      : AppColors.rosePink,
                  fontFamily: GoogleFonts.comfortaa().fontFamily,
                ),
                child: const Text('Trending'),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            left: _showFollowing ? 0 : screenWidth * 0.55,
            bottom: _showFollowing ? 4 : 12,
            child: InkWell(
              onTap: () {
                setState(() => _showFollowing = true);
                _pageController.jumpToPage(0);
                _currentPage = 0;
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                style: TextStyle(
                  fontSize: _showFollowing ? 36 : 22,
                  fontWeight: _showFollowing
                      ? FontWeight.w900
                      : FontWeight.bold,
                  color: _showFollowing
                      ? AppColors.rosePink
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                  fontFamily: GoogleFonts.comfortaa().fontFamily,
                ),
                child: const Text('Following'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
