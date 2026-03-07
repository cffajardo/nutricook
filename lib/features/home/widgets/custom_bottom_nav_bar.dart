import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<IconData> _icons = <IconData>[
    Icons.restaurant_menu_rounded,
    Icons.calendar_today_rounded,
    Icons.home_rounded,
    Icons.local_library_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: List<Widget>.generate(_icons.length, (index) {
            final selected = index == currentIndex;
            final center = index == 2;
            if (center) {
              return Expanded(
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => onTap(index),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.rosePink
                            : AppColors.cardRose,
                        border: Border.all(
                          color: selected
                              ? AppColors.rosePink
                              : Colors.black.withValues(alpha: 0.25),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _icons[index],
                        color: selected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Expanded(
              child: Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 40,
                    height: 34,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.inputRose
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.rosePink
                            : Colors.black.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Icon(
                      _icons[index],
                      size: 20,
                      color: selected ? AppColors.rosePink : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
