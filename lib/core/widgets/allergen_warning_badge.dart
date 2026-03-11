import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';

class AllergenWarningBadge extends StatelessWidget {
  const AllergenWarningBadge({
    super.key,
    required this.allergenLabels,
  });

  final List<String> allergenLabels;

  @override
  Widget build(BuildContext context) {
    if (allergenLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAllergenDialog(context),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFD92D20),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _showAllergenDialog(BuildContext context) {
    final allergenText = allergenLabels.join(', ');
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Color(0xFFD92D20)),
              SizedBox(width: 10),
              Text(
                'Allergen Warning',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            'Contains Allergen: $allergenText',
            style: const TextStyle(fontSize: 14.5, height: 1.35),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.rosePink),
              ),
            ),
          ],
        );
      },
    );
  }
}