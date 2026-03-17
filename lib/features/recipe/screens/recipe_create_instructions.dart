import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/add_step_entry.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';

class CreateRecipeInstructionsPage extends ConsumerWidget {
  final VoidCallback onBack;
  final Future<void> Function() onFinish;
  final bool isFinishing;

  const CreateRecipeInstructionsPage({
    super.key,
    required this.onBack,
    required this.onFinish,
    this.isFinishing = false,
  });

  void _showStepModal(
    BuildContext context,
    WidgetRef ref, {
    RecipeStep? initialStep,
    int? index,
    required int stepNumber,
  }) {
    final recipeState = ref.watch(recipeCreationProvider);
    final maxTimeSeconds = (recipeState.prepTimeMinutes + recipeState.cookTimeMinutes) * 60;
    
    int otherStepsSum = 0;
    for (int i = 0; i < recipeState.steps.length; i++) {
      if (i != index) {
        otherStepsSum += recipeState.steps[i].timerSeconds;
      }
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStepModal(
        initialStep: initialStep,
        stepNumber: stepNumber,
        maxAllowedTimeSeconds: maxTimeSeconds,
        otherStepsTimeSeconds: otherStepsSum,
        onStepAdded: (result) {
          if (index != null) {
            ref.read(recipeCreationProvider.notifier).updateStep(index, result);
          } else {
            ref.read(recipeCreationProvider.notifier).addStep(result);
          }
        },
        onStepDeleted: index == null
            ? null
            : () => ref.read(recipeCreationProvider.notifier).removeStep(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(recipeCreationProvider).steps;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Instructions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                if (steps.isEmpty)
                  _buildEmptyState(context, ref, stepNumber: 1)
                else
                  _buildStepList(context, ref, steps),
              ],
            ),
          ),
        ),
        _buildNavigationButtons(steps),
      ],
    );
  }

  Widget _buildStepList(
    BuildContext context,
    WidgetRef ref,
    List<RecipeStep> steps,
  ) {
    return Column(
      children: [
        ...steps.asMap().entries.map((entry) {
          int idx = entry.key;
          var step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => _showStepModal(
                context,
                ref,
                initialStep: step,
                index: idx,
                stepNumber: idx + 1,
              ),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.rosePink,
                      radius: 12,
                      child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.instruction, style: const TextStyle(fontSize: 15, height: 1.4)),
                          if (step.timerSeconds > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.rosePink),
                                  const SizedBox(width: 4),
                                  Text(_formatDuration(step.timerSeconds), style: const TextStyle(color: AppColors.rosePink, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, size: 18, color: Colors.black12),
                  ],
                ),
              ),
            ),
          );
        }),
        IconButton(
          onPressed: () => _showStepModal(
            context,
            ref,
            stepNumber: steps.length + 1,
          ),
          icon: const Icon(Icons.add_circle_outline, color: AppColors.rosePink, size: 32),
        ),
      ],
    );
  }

  String _formatDuration(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref, {
    required int stepNumber,
  }) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          IconButton(
            onPressed: () =>
                _showStepModal(context, ref, stepNumber: stepNumber),
            icon: const Icon(Icons.add_circle_outline, size: 80, color: AppColors.rosePink),
          ),
          const SizedBox(height: 16),
          const Text('Tap + to add your first step', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(List<RecipeStep> steps) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(minimumSize: const Size(0, 55), side: const BorderSide(color: AppColors.rosePink, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Back', style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: steps.isEmpty || isFinishing ? null : onFinish,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosePink, minimumSize: const Size(0, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: isFinishing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Finish Recipe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}