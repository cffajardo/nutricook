import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';

class RecipeViewIngredients extends StatelessWidget {
  final List<RecipeIngredient> ingredients;

  const RecipeViewIngredients({super.key, required this.ingredients});

  static const double _epsilon = 1e-6;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Main Ingredients', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.5), 
            ),
            child: ListView.separated(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: ingredients.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.black12,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = ingredients[index];
                final String process = item.preparation ?? '';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: process.isNotEmpty 
                      ? Text(process, style: const TextStyle(fontSize: 12, color: Colors.black38)) 
                      : null,
                  trailing: Text(
                    _formatQuantityAndUnit(item),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900, 
                      color: AppColors.rosePink,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _formatQuantityAndUnit(RecipeIngredient item) {
    final isGramUnit = item.unitID.toLowerCase() == 'g' ||
        item.unitName.toLowerCase() == 'gram' ||
        item.unitName.toLowerCase() == 'grams';

    final quantityText = isGramUnit
        ? item.quantity.round().toString()
        : _formatAsMixedFraction(item.quantity);

    final unitText = _pluralizeUnit(
      unitName: item.unitName,
      quantity: item.quantity,
    );

    return '$quantityText $unitText';
  }

  String _formatAsMixedFraction(double value) {
    final roundedInt = value.roundToDouble();
    if ((value - roundedInt).abs() < _epsilon) {
      return roundedInt.toInt().toString();
    }

    final whole = value.truncate();
    final fraction = value - whole;

    const denominators = <int>[2, 3, 4, 5, 6, 8, 10, 12, 16];
    var bestDen = 1;
    var bestNum = 0;
    var bestDiff = double.infinity;

    for (final den in denominators) {
      final num = (fraction * den).round();
      final diff = (fraction - (num / den)).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestDen = den;
        bestNum = num;
      }
    }

    if (bestNum == 0) {
      return whole.toString();
    }

    if (bestNum == bestDen) {
      return (whole + 1).toString();
    }

    if (whole == 0) {
      return '$bestNum/$bestDen';
    }

    return '$whole $bestNum/$bestDen';
  }

  String _pluralizeUnit({required String unitName, required double quantity}) {
    final lower = unitName.toLowerCase();
    final isSingular = (quantity - 1).abs() < _epsilon;

    if (isSingular) {
      if (lower == 'pieces') return 'piece';
      if (lower == 'grams') return 'gram';
      return lower;
    }

    if (lower == 'piece') return 'pieces';
    if (lower == 'gram') return 'grams';
    if (lower.endsWith('s')) return lower;
    return '${lower}s';
  }
}