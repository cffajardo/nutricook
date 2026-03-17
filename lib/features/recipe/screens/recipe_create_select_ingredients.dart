import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/add_ingredient_modal.dart';
import 'package:nutricook/models/recipe_ingredient/recipe_ingredient.dart';

class CreateRecipeIngredientsPage extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CreateRecipeIngredientsPage({super.key, required this.onNext, required this.onBack});

  void _showAddModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIngredientModal(
        onIngredientAdded: (item) =>
            ref.read(recipeCreationProvider.notifier).addIngredient(item),
      ),
    );
  }

  void _showEditModal(
    BuildContext context,
    WidgetRef ref,
    RecipeIngredient ingredient,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIngredientModal(
        initialIngredient: ingredient,
        onIngredientAdded: (result) =>
            ref.read(recipeCreationProvider.notifier).updateIngredient(index, result),
        onIngredientDeleted: () =>
            ref.read(recipeCreationProvider.notifier).removeIngredient(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients = ref.watch(recipeCreationProvider).ingredients;
    return Column(
      children: [
        Expanded(
          child: ingredients.isEmpty
              ? _buildEmptyState(context, ref)
              : _buildIngredientList(context, ref, ingredients),
        ),
        _buildNavigationButtons(ingredients),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _showAddModal(context, ref),
            icon: const Icon(Icons.add_circle_outline, size: 80, color: AppColors.rosePink),
          ),
          const SizedBox(height: 16),
          const Text('Tap to add ingredients', 
            style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIngredientList(
    BuildContext context,
    WidgetRef ref,
    List<RecipeIngredient> ingredients,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: ingredients.length + 1,
      itemBuilder: (context, index) {
        if (index == ingredients.length) {
          return IconButton(
            onPressed: () => _showAddModal(context, ref),
            icon: const Icon(Icons.add_circle_outline, color: AppColors.rosePink, size: 32),
          );
        }

        final item = ingredients[index];
        final String process = item.preparation ?? '';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showEditModal(context, ref, item, index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.1), width: 1.5),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      if (process.isNotEmpty) 
                        Text(process, style: const TextStyle(fontSize: 12, color: Colors.black38)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${_formatQuantity(item.quantity)} ${item.unitName}${process.isNotEmpty ? " • $process" : ""}', 
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.rosePink),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_outlined, size: 16, color: AppColors.rosePink),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(List<RecipeIngredient> ingredients) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 55),
                side: const BorderSide(color: AppColors.rosePink, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Back', style: TextStyle(color: AppColors.rosePink, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: ingredients.isEmpty ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rosePink,
                minimumSize: const Size(0, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    var text = value.toStringAsFixed(2);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }
}