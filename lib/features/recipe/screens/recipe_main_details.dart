import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/allergen_entries.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/collection/provider/collection_provider.dart';
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
import 'package:nutricook/features/utils/nutrition_calculator.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/services/collection_item_service.dart';

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

  final List<String> _pageTitles = ['About', 'Ingredients', 'Instructions'];

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
    final rootMessenger = ScaffoldMessenger.of(
      Navigator.of(context, rootNavigator: true).context,
    );

    final selectedCollectionId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final collectionsAsync = ref.watch(userCollectionsProvider);

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: collectionsAsync.when(
            loading: () => const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SizedBox(
              height: 180,
              child: Center(child: Text('Failed to load collections: $error')),
            ),
            data: (collections) {
              if (collections.isEmpty) {
                return const SizedBox(
                  height: 180,
                  child: Center(
                    child: Text('Create a collection first from Collections.'),
                  ),
                );
              }

              return Column(
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
                      'Add to collection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: collections.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final collection = collections[index];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.rosePink.withValues(alpha: 0.2),
                            ),
                          ),
                          title: Text(collection.name),
                          subtitle: Text('${collection.recipeCount} recipes'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.pop(context, collection.id),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (selectedCollectionId == null) return;

    try {
      final service = CollectionItemService();
      await service.addItemToCollection(
        collectionId: selectedCollectionId,
        recipeId: widget.recipe.id,
        recipeName: widget.recipe.name,
        thumbnailUrl: widget.recipe.imageURL.isNotEmpty
            ? widget.recipe.imageURL.first
            : null,
        tags: widget.recipe.tags,
        prepTime: widget.recipe.prepTime,
        cookTime: widget.recipe.cookTime,
      );

      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Added to collection.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed to add to collection: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
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

  Future<void> _deleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete recipe?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
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
      await ref.read(recipeServiceProvider).deleteRecipe(widget.recipe.id);
      if (!mounted) return;
      Navigator.pop(context);
      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Recipe deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      rootMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed to delete recipe: $error'),
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

    final reason = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) {
        const reasons = <String>[
          'Spam',
          'Inappropriate content',
          'Unsafe instructions',
          'Plagiarism',
        ];
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

    try {
      await ref
          .read(recipeReportServiceProvider)
          .submitReport(recipeId: widget.recipe.id, reason: reason);
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
        color: Colors.white,
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
                  _pageTitles[index],
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
