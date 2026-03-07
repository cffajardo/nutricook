import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Add GoRouter
import 'package:nutricook/core/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  // We removed currentIndex and onTap from the constructor!
  const CustomBottomNavBar({super.key});

  static const List<IconData> _icons = <IconData>[
    Icons.restaurant_menu_rounded,
    Icons.calendar_today_rounded,
    Icons.home_rounded,
    Icons.local_library_rounded,
    Icons.person_rounded,
  ];

  // --- GO ROUTER LOGIC ---
  // Automatically determines which icon is active based on the current URL
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    
    if (location.startsWith('/recipes')) return 0; // Replace with actual route
    if (location.startsWith('/planner')) return 1;
    if (location == '/') return 2;
    if (location.startsWith('/library')) return 3; // Replace with actual route
    if (location.startsWith('/profile')) return 4; // Replace with actual route
    
    return 2; // Default to home if unknown
  }

  // Triggers the actual navigation
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        // context.go('/recipes'); // Uncomment when you build this screen
        break;
      case 1:
        context.go('/planner');
        break;
      case 2:
        context.go('/');
        break;
      case 3:
        // context.go('/library'); // Uncomment when you build this screen
        break;
      case 4:
        // context.go('/profile'); // Uncomment when you build this screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the active index dynamically
    final currentIndex = _calculateSelectedIndex(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_icons.length, (index) {
                  final isSelected = index == currentIndex;
                  final isCenter = index == 2;

                  if (isCenter) return _buildCenterItem(index, isSelected, context);
                  return _buildSideItem(index, isSelected, context);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterItem(int index, bool selected, BuildContext context) {
    return InkWell(
      // Removed the grey splash effect for a premium feel
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _onItemTapped(index, context),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.rosePink : AppColors.cardRose,
        ),
        child: Icon(_icons[index], color: selected ? Colors.white : Colors.black87, size: 28),
      ),
    );
  }

  Widget _buildSideItem(int index, bool selected, BuildContext context) {
    return InkWell(
      // Removed the grey splash effect for a premium feel
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _onItemTapped(index, context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.inputRose : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(_icons[index], size: 22, color: selected ? AppColors.rosePink : Colors.black54),
      ),
    );
  }
}