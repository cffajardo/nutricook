import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/allergen_entries.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/planner/widgets/planner_item_edit_modal.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/features/recipe/screens/recipe_about_detail.dart';
import 'package:nutricook/features/recipe/screens/recipe_ingredient_detail.dart';
import 'package:nutricook/features/recipe/screens/recipe_instruction_detail.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_report_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_fab_modal.dart';
import 'package:nutricook/features/collection/screens/add_to_collections_modal.dart';
import 'package:nutricook/features/utils/nutrition_calculator.dart';
import 'package:nutricook/services/archive_service.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:share_plus/share_plus.dart';

class RecipeDetailsScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailsScreen> createState() =>
      _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends ConsumerState<RecipeDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _startCookingSignal = 0;

  List<String> get _pageTitles => [widget.recipe.name, 'Ingredients', 'Instructions'];

  List<String> get _bottomNavTitles => ['About', 'Ingredients', 'Instructions'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openPlannerModal() async {
    if (!mounted) return;
    final nutritionPerServing =
        widget.recipe.nutritionPerServing ??
        (widget.recipe.nutritionTotal != null && widget.recipe.servings > 0
            ? NutritionCalculator.calculateNutritionPerServing(
                totalNutrition: widget.recipe.nutritionTotal!,
                servings: widget.recipe.servings,
              )
            : null);

    final allergenWarnings = matchedRecipeAllergenLabels(
      recipe: widget.recipe,
      allergenEntries:
          ref.read(userAllergenProvider).asData?.value ?? const <String>[],
      ingredientsMap: ref.read(ingredientsMapProvider).asData?.value,
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlannerItemEditModal(
        initialMealType: 'Dinner',
        initialRecipeData: <String, dynamic>{
          'id': widget.recipe.id,
          'name': widget.recipe.name,
          'servings': widget.recipe.servings,
          'thumbnailUrl': widget.recipe.imageURL.isNotEmpty
              ? widget.recipe.imageURL.first
              : null,
          'prepTime': widget.recipe.prepTime,
          'cookTime': widget.recipe.cookTime,
          'nutritionPerServing': nutritionPerServing,
          'allergenWarnings': allergenWarnings,
        },
      ),
    );
  }

  Future<void> _addToCollection() async {
    if (!mounted) return;
    
    final currentUserId = ref.read(currentUserIdProvider);
    final isRecipeLiked =
        currentUserId != null && widget.recipe.favoritedBy.contains(currentUserId);

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddToCollectionsModal(
        recipeId: widget.recipe.id,
        recipeName: widget.recipe.name,
        thumbnailUrl: widget.recipe.imageURL.isNotEmpty
            ? widget.recipe.imageURL.first
            : null,
        tags: widget.recipe.tags,
        prepTime: widget.recipe.prepTime,
        cookTime: widget.recipe.cookTime,
        isRecipeLiked: isRecipeLiked,
      ),
    );
  }

  Future<void> _editAsCopy() async {
    final notifier = ref.read(recipeCreationProvider.notifier);
    notifier.clear();
    notifier.updateAbout(
      name: '${widget.recipe.name} (Copy)',
      description: widget.recipe.description,
      prepTimeMinutes: widget.recipe.prepTime,
      cookTimeMinutes: widget.recipe.cookTime,
      servings: widget.recipe.servings,
      isPublic: widget.recipe.isPublic,
      tags: widget.recipe.tags,
    );

    for (final ingredient in widget.recipe.ingredients) {
      notifier.addIngredient(ingredient);
    }
    for (final step in widget.recipe.steps) {
      notifier.addStep(step);
    }

    if (!mounted) return;
    context.pushNamed(AppRoutes.recipeCreateName);
  }

  Future<void> _editRecipe() async {
    final notifier = ref.read(recipeCreationProvider.notifier);
    notifier.clear();
    notifier.setEditingRecipeId(widget.recipe.id);
    notifier.updateAbout(
      name: widget.recipe.name,
      description: widget.recipe.description,
      prepTimeMinutes: widget.recipe.prepTime,
      cookTimeMinutes: widget.recipe.cookTime,
      servings: widget.recipe.servings,
      isPublic: widget.recipe.isPublic,
      tags: widget.recipe.tags,
    );

    for (final ingredient in widget.recipe.ingredients) {
      notifier.addIngredient(ingredient);
    }
    for (final step in widget.recipe.steps) {
      notifier.addStep(step);
    }

    if (!mounted) return;
    context.pushNamed(AppRoutes.recipeCreateName);
  }

  Future<void> _deleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move to Archive?'),
          content: const Text(
            'This recipe will be moved to your archive. '
            'You can restore it later from Settings → Archive.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Archive',
                style: TextStyle(color: AppColors.rosePink),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final rootMessenger = ScaffoldMessenger.of(
      Navigator.of(context, rootNavigator: true).context,
    );
    try {
      await ref.read(archiveServiceProvider).archiveItem(
            collection: AppConstants.collectionRecipes,
            docId: widget.recipe.id,
          );
      if (!mounted) return;
      Navigator.pop(context);
      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Recipe moved to archive.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed to archive recipe: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _reportRecipe() async {
    final hasReported = await ref.read(
      hasCurrentUserReportedRecipeProvider(widget.recipe.id).future,
    );
    if (hasReported) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already reported this recipe.')),
      );
      return;
    }

    const reasons = <String>[
      'Spam',
      'Inappropriate content',
      'Unsafe instructions',
      'Plagiarism',
    ];

    final reason = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Report reason',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              ...reasons.map(
                (item) => ListTile(
                  title: Text(item),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, item),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (reason == null) return;

    final description = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final controller = TextEditingController();
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Describe the problem (optional)',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 4,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Please explain what the issue is...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.rosePink),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rosePink,
                  ),
                  child: const Text('Submit Report'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    try {
      await ref
          .read(recipeReportServiceProvider)
          .submitReport(
            recipeId: widget.recipe.id,
            reason: reason,
            details: description?.isNotEmpty == true ? description : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to report recipe: $error')),
      );
    }
  }

  void _shareRecipe() {
    try {
      final buffer = StringBuffer();
      
      buffer.writeln('═════════════════════════════');
      buffer.writeln(widget.recipe.name.toUpperCase());
      buffer.writeln('═════════════════════════════\n');
      
      buffer.writeln('📋 Recipe Details');
      buffer.writeln('Servings: ${widget.recipe.servings}');
      buffer.writeln('Prep Time: ${widget.recipe.prepTime} min');
      buffer.writeln('Cook Time: ${widget.recipe.cookTime} min\n');
      
      if (widget.recipe.nutritionTotal != null) {
        final nutrition = widget.recipe.nutritionTotal!;
        buffer.writeln('🥗 Nutrition (per serving)');
        buffer.writeln('Calories: ${nutrition.calories.toStringAsFixed(0)} kcal');
        buffer.writeln('Protein: ${nutrition.protein.toStringAsFixed(1)}g');
        buffer.writeln('Carbs: ${nutrition.carbohydrates.toStringAsFixed(1)}g');
        buffer.writeln('Fat: ${nutrition.fat.toStringAsFixed(1)}g');
        buffer.writeln('Fiber: ${nutrition.fiber.toStringAsFixed(1)}g');
        buffer.writeln('Sugar: ${nutrition.sugar.toStringAsFixed(1)}g');
        buffer.writeln('Sodium: ${(nutrition.sodium / 1000).toStringAsFixed(1)}g\n');
      }
      
      if (widget.recipe.ingredients.isNotEmpty) {
        buffer.writeln('🛒 Ingredients');
        for (final ingredient in widget.recipe.ingredients) {
          buffer.writeln('• ${ingredient.name}');
          buffer.writeln('  ${ingredient.quantity} ${ingredient.unitName}');
          if (ingredient.preparation != null && ingredient.preparation!.isNotEmpty) {
            buffer.writeln('  (${ingredient.preparation})');
          }
        }
        buffer.writeln('');
      }
      
      if (widget.recipe.steps.isNotEmpty) {
        buffer.writeln('👨‍🍳 Instructions');
        for (int i = 0; i < widget.recipe.steps.length; i++) {
          buffer.writeln('${i + 1}. ${widget.recipe.steps[i].instruction}');
        }
        buffer.writeln('');
      }
      
      buffer.writeln('══════════════════════');
      buffer.writeln('Shared from NutriCook');
      buffer.writeln('══════════════════════');
      
      SharePlus.instance.share(
        ShareParams(
          text: buffer.toString(),
          subject: widget.recipe.name,
        )
      );

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share recipe: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isOwner =
        widget.recipe.ownerId != null && widget.recipe.ownerId == currentUserId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          _pageTitles[_currentPage],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    RecipeViewAbout(recipe: widget.recipe),
                    RecipeViewIngredients(
                      ingredients: widget.recipe.ingredients,
                    ),
                    RecipeViewInstructions(
                      steps: widget.recipe.steps,
                      startCookingSignal: _startCookingSignal,
                    ),
                  ],
                ),
              ),
              _buildBottomIndicator(),
            ],
          ),
          Positioned(
            bottom: 115,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => RecipeActionsModal(
                    recipe: widget.recipe,
                    isOwner: isOwner,
                    onStartCooking: () {
                      Navigator.pop(context);
                      setState(() => _startCookingSignal += 1);
                      _onTabTapped(2);
                    },
                    onAddToPlanner: () {
                      Navigator.pop(context);
                      _openPlannerModal();
                    },
                    onAddToCollection: () {
                      Navigator.pop(context);
                      _addToCollection();
                    },
                    onEdit: () {
                      Navigator.pop(context);
                      _editRecipe();
                    },
                    onEditCopy: () {
                      Navigator.pop(context);
                      _editAsCopy();
                    },
                    onDelete: () {
                      Navigator.pop(context);
                      _deleteRecipe();
                    },
                    onReport: () {
                      Navigator.pop(context);
                      _reportRecipe();
                    },
                    onShare: () {
                      Navigator.pop(context);
                      _shareRecipe();
                    },
                  ),
                );
              },
              backgroundColor: AppColors.rosePink,
              elevation: 6,
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Container(
      padding: EdgeInsets.only(
        top: 15,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final isSelected = _currentPage == index;

          return InkWell(
            onTap: () => _onTabTapped(index),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.rosePink.withValues(alpha: 0.08)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.rosePink : Colors.black12,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForIndex(index),
                    color: isSelected ? AppColors.rosePink : Colors.black26,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _bottomNavTitles[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    color: isSelected ? AppColors.rosePink : Colors.black26,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.info_outline_rounded;
      case 1:
        return Icons.restaurant_menu_rounded;
      case 2:
        return Icons.format_list_numbered_rounded;
      default:
        return Icons.help_outline;
    }
  }
}
