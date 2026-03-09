import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onProfileTap,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: 'Search recipes',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppColors.rosePink,
                  width: 1.6,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.black.withValues(alpha: 0.18)),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
