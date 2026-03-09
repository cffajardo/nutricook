import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:nutricook/features/home/widgets/home_category_row.dart';
import 'package:nutricook/features/home/widgets/home_meal_view.dart'; 
import 'package:nutricook/features/home/widgets/home_search_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const List<String> _categories = <String>['Cuisine', 'Dietary', 'Nutrition', 'Difficulty'];

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
  
  String get _autoMealType {
    final hour = _now.hour;
    if (hour < 11) return 'Breakfast';
    if (hour < 16) return 'Lunch';
    if (hour < 22) return 'Dinner';
    return 'Snack';
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  HomeSearchBar(controller: _searchController, onProfileTap: () {}),
                  const SizedBox(height: 20),
                  _buildTabs(),
                  const SizedBox(height: 16),
 
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: AppColors.cardRose,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.rosePink.withValues(alpha: 0.14),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (int page) => setState(() => _currentPage = page),
                            itemCount: 3, // Shows 3 sliding pages
                            itemBuilder: (context, index) {
                              return _showFollowing 
                                ? const _FollowingContent() 
                                : _TrendingContent(index: index);
                            },
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) => _buildDot(index)),
                        ),
                      ),
                    ],
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
                    onCategorySelected: (val) => setState(() => _selectedCategory = val),
                  ),
                  const SizedBox(height: 24),
                  HomeMealOverviewCard(
                    date: _selectedDate,
                    mealType: _autoMealType,
                    items: const [1],
                    totals: '350 Calories • 12g Protein • 8g Fats • 45g Carbs',
                    isTotalsLoading: false,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: CustomBottomNavBar()),
        ],
      ),
    );
  }


  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 20 : 8, 
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.rosePink : AppColors.rosePink.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTabs() {
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
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                style: TextStyle(
                  fontSize: _showFollowing ? 22 : 36,
                  fontWeight: _showFollowing ? FontWeight.bold : FontWeight.w900,
                  color: _showFollowing ? Colors.black38 : AppColors.rosePink, 
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
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                style: TextStyle(
                  fontSize: _showFollowing ? 36 : 22,
                  fontWeight: _showFollowing ? FontWeight.w900 : FontWeight.bold,
                  color: _showFollowing ? AppColors.rosePink : Colors.black38,
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

class _TrendingContent extends StatelessWidget {
  final int index;
  const _TrendingContent({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            index == 0 ? 'Creamy Pasta' : 'Spicy Tacos', 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.rosePink, borderRadius: BorderRadius.circular(10)),
            child: const Text('Lunch', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12), 
        ],
      ),
    );
  }
}

class _FollowingContent extends StatelessWidget {
  const _FollowingContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, color: AppColors.rosePink.withValues(alpha: 0.4), size: 48),
          const SizedBox(height: 12),
          Text(
            'Follow chefs to see their recipes!',
            style: TextStyle(color: AppColors.rosePink.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12), 
        ],
      ),
    );
  }
}