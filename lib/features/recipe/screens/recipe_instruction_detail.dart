import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';

class RecipeViewInstructions extends StatelessWidget {
  final List<RecipeStep> steps;

  const RecipeViewInstructions({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), 
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final int timerSeconds = step.timerSeconds;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 1.5), 
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.rosePink,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.instruction,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    
                    // 3. TIMER CHIP (Only shows if timer exists)
                    if (timerSeconds > 0) ...[
                      const SizedBox(height: 12),
                      _buildTimerChip(timerSeconds),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerChip(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;

    String timeStr = '';
    if (h > 0) timeStr += '${h}h ';
    if (m > 0) timeStr += '${m}m ';
    if (s > 0 || timeStr.isEmpty) timeStr += '${s}s';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: AppColors.rosePink),
          const SizedBox(width: 6),
          Text(
            timeStr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.rosePink,
            ),
          ),
        ],
      ),
    );
  }
}