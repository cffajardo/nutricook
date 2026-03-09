import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class HomeCategoryRow extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const HomeCategoryRow({super.key, required this.categories, required this.selectedCategory, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final double size = (MediaQuery.of(context).size.width - 80) / 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        final bool sel = cat == selectedCategory;
        return GestureDetector(
          onTap: () => onCategorySelected(cat),
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sel ? AppColors.rosePink : AppColors.rosePink.withValues(alpha: 0.14), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Positioned.fill(child: Image.asset('assets/images/${cat.toLowerCase()}.jpg', fit: BoxFit.cover)),
                  Positioned.fill(child: Container(decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                      Colors.transparent, AppColors.rosePink.withValues(alpha: sel ? 0.85 : 0.6)
                    ]),
                  ))),
                  Center(child: Text(cat, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}