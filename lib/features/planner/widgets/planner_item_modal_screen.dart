import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/planner/provider/planner_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/planner/widgets/planner_item_edit_modal.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';
import 'package:nutricook/routing/app_routes.dart';

class PlannerItemModal extends ConsumerWidget {
  final PlannerItem item;

  const PlannerItemModal({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmedNotes = item.notes?.trim() ?? '';
    final calories =
        ((item.nutritionPerServing?.calories ?? 0) * item.servingMultiplier)
            .round();
    final protein =
        (item.nutritionPerServing?.protein ?? 0) * item.servingMultiplier;
    final fat = (item.nutritionPerServing?.fat ?? 0) * item.servingMultiplier;
    final carbs =
        (item.nutritionPerServing?.carbohydrates ?? 0) * item.servingMultiplier;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.6,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.rosePink,
                  size: 32,
                ),
              ),
              const Text(
                'Recipe Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await ref.read(plannerServiceProvider).deletePlannerItem(item.id);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.rosePink,
                      size: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => PlannerItemEditModal(item: item),
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.rosePink,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              physics: const BouncingScrollPhysics(),
              children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 64,
                color: Colors.black12,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.rosePink,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Name', item.recipeName),
                const Divider(height: 24),
                _buildDetailRow(
                  'Date',
                  DateFormat('MMMM d, yyyy').format(item.date),
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Recipe servings',
                  '${_formatServingMultiplier(item.servingMultiplier)}',
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Nutrition basis',
                  '$calories kcal',
                ),
                const Divider(height: 24),
                _buildDetailRow('Meal Time', item.mealType),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildNutritionHero(
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            fiber: (item.nutritionPerServing?.fiber ?? 0) * item.servingMultiplier,
            sugar: (item.nutritionPerServing?.sugar ?? 0) * item.servingMultiplier,
            sodium: (item.nutritionPerServing?.sodium ?? 0) * item.servingMultiplier,
          ),

          if (trimmedNotes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rosePink,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                trimmedNotes,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.45,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () async {
                  final rootMessenger = ScaffoldMessenger.of(
                    Navigator.of(context, rootNavigator: true).context,
                  );
                  try {
                    final recipe = await ref
                        .read(recipeServiceProvider)
                        .getRecipeById(item.recipeId)
                        .first;

                    if (recipe == null || !context.mounted) {
                      return;
                    }

                    Navigator.pop(context);
                    context.pushNamed(
                      AppRoutes.recipeDetailsName,
                      extra: recipe,
                    );
                  } catch (error) {
                    if (!context.mounted) return;
                    rootMessenger.showSnackBar(
                      SnackBar(content: Text('Unable to open recipe: $error')),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.rosePink, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Open Recipe',
                  style: TextStyle(
                    color: AppColors.rosePink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(plannerServiceProvider)
                      .togglePlannerItemCompletion(item.id, !item.isCompleted);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosePink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  item.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

              ],
            ),
          ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionHero({
    required int calories,
    required double protein,
    required double fat,
    required double carbs,
    required double fiber,
    required double sugar,
    required double sodium,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.rosePink,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.rosePink.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeroStat('Calories', '$calories', 'kcal'),
            _buildDivider(),
            _buildHeroStat('Protein', protein.toStringAsFixed(1), 'g'),
            _buildDivider(),
            _buildHeroStat('Carbs', carbs.toStringAsFixed(1), 'g'),
            _buildDivider(),
            _buildHeroStat('Fat', fat.toStringAsFixed(1), 'g'),
            _buildDivider(),
            _buildHeroStat('Fiber', fiber.toStringAsFixed(1), 'g'),
            _buildDivider(),
            _buildHeroStat('Sugars', sugar.toStringAsFixed(1), 'g'),
            _buildDivider(),
            _buildHeroStat('Sodium', (sodium / 1000).toStringAsFixed(1), 'g'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 35, color: Colors.white24);

  String _formatServingMultiplier(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    var text = value.toStringAsFixed(2);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
