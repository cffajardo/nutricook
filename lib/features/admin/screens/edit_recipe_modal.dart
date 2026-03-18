import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/screens/recipe_create_flow.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class EditRecipeModal extends ConsumerStatefulWidget {
  final String recipeId;

  const EditRecipeModal({super.key, required this.recipeId});

  @override
  ConsumerState<EditRecipeModal> createState() => _EditRecipeModalState();
}

class _EditRecipeModalState extends ConsumerState<EditRecipeModal> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAndPrefill();
  }

  Future<void> _loadAndPrefill() async {
    try {
      final doc = await FirebaseFirestore.instance.collection(FirestoreConstants.recipes).doc(widget.recipeId).get();
      if (!mounted) return;
      if (doc.exists) {
        final recipe = Recipe.fromJson({...doc.data()!, 'id': doc.id});

        final notifier = ref.read(recipeCreationProvider.notifier);
        notifier.clear();
        notifier.setEditingRecipeId(recipe.id);
        notifier.updateAbout(
          name: recipe.name,
          description: recipe.description,
          prepTimeMinutes: recipe.prepTime,
          cookTimeMinutes: recipe.cookTime,
          servings: recipe.servings,
          isPublic: recipe.isPublic,
          tags: recipe.tags,
        );

        if (recipe.imageURL.isNotEmpty) {
          notifier.setImageUrl(recipe.imageURL.first);
        }

        for (final ing in recipe.ingredients) notifier.addIngredient(ing);
        for (final s in recipe.steps) notifier.addStep(s);
      }
    } catch (e) {
      debugPrint('Error pre-filling recipe creation provider: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final creation = ref.watch(recipeCreationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Editing Recipe',
                        style: TextStyle(
                          color: AppColors.rosePink,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        creation.name.isNotEmpty ? creation.name : 'Untitled Recipe',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RecipeCreateFlow(),
          ),
        ],
      ),
    );
  }
}
