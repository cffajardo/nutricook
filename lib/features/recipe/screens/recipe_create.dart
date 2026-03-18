import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/library/units/unit_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_select_ingredients.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_about_page.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_instructions.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_flow.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/features/admin/providers/create_ingredient_provider.dart';

class CreateRecipeScreen extends ConsumerWidget {
  const CreateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(recipeCreationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            final creation = ref.read(recipeCreationProvider);
            final cleanupId = creation.creationId;

            if (creation.tempIngredientIds.isNotEmpty) {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cancel Creation?'),
                  content: const Text('Closing will delete any custom ingredients you just created for this recipe.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Working')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), 
                      child: const Text('Discard', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;

              await ref.read(recipeCreationProvider.notifier).cleanupTempIngredients(cleanupId);
            }

            ref.read(recipeCreationProvider.notifier).clear();
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: Colors.black87),
        ),
        title: Builder(
          builder: (context) {
            final creation = ref.watch(recipeCreationProvider);
            return Text(
              '${creation.isEditing ? 'Edit' : 'Create'} Recipe',
              style: const TextStyle(
                color: AppColors.rosePink,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: RecipeCreateFlow(),
    );
  }
}
