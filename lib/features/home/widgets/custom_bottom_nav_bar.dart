import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/routing/app_routes.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  static const List<IconData> _icons = <IconData>[
    Icons.restaurant_menu_rounded,
    Icons.calendar_today_rounded,
    Icons.home_rounded,
    Icons.local_library_rounded,
    Icons.person_rounded,
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    if (location.startsWith(AppRoutes.recipesPath)) return 0;
    if (location.startsWith(AppRoutes.plannerPath)) return 1;
    if (location == AppRoutes.homePath) return 2;
    if (location.startsWith(AppRoutes.libraryPath)) return 3;
    if (location.startsWith(AppRoutes.profilePath)) return 4;

    return 2;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.recipesPath);
        break;
      case 1:
        context.go(AppRoutes.plannerPath);
        break;
      case 2:
        context.go(AppRoutes.homePath);
        break;
      case 3:
        context.go(AppRoutes.libraryPath);
        break;
      case 4:
        context.go(AppRoutes.profilePath);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, -4), // top shadow
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final isSelected = index == currentIndex;
            final isCenter = index == 2;

            if (isCenter) {
              return _buildCenterItem(index, isSelected, context);
            }
            return _buildSideItem(index, isSelected, context);
          }),
        ),
      ),
    );
  }

  Widget _buildCenterItem(int index, bool selected, BuildContext context) {
    return InkWell(
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
        child: Icon(
          _icons[index],
          color: selected ? Colors.white : Colors.black87,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSideItem(int index, bool selected, BuildContext context) {
    return InkWell(
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
        child: Icon(
          _icons[index],
          size: 22,
          color: selected ? AppColors.rosePink : Colors.black54,
        ),
      ),
    );
  }
}