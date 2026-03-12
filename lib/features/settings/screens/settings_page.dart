import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/allergen_entries.dart';
import 'package:nutricook/core/meal_time_preferences.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/features/recipe/widgets/add_ingredient_modal.dart';
import 'package:nutricook/models/user_preferences/user_preferences.dart';
import 'package:nutricook/routing/app_routes.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(userPreferencesProvider);
    final user = ref.watch(authStateProvider).asData?.value;
    final isAdmin = ref.watch(isCurrentUserAdminProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9FA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.rosePink,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (preferences) {
          final notifier = ref.read(userPreferencesProvider.notifier);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            physics: const BouncingScrollPhysics(),
            children: [
              _SectionHeader(label: 'Account'),
              _SettingsCard(
                children: [
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: 'Username',
                    value: user?.displayName?.isNotEmpty == true
                        ? user!.displayName!
                        : '—',
                  ),
                  const _Divider(),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? '—',
                  ),
                  const _Divider(),
                  _ActionRow(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    color: Colors.redAccent,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('Sign out?'),
                          content: const Text(
                            'You will be returned to the login screen.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Sign Out',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(authProvider).signOut();
                      }
                    },
                  ),
                  if (isAdmin) ...[
                    const _Divider(),
                    _ActionRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin Panel',
                      onTap: () => context.pushNamed(AppRoutes.adminName),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'Nutrition'),
              _SettingsCard(
                children: [
                  _CalorieGoalRow(
                    current: preferences.dailyCalorieGoal,
                    onChanged: notifier.updateDailyCalorieGoal,
                  ),
                  const _Divider(),
                  _SwitchRow(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Nutrition per serving',
                    value: preferences.showNutritionPerServing,
                    onChanged: notifier.updateShowNutritionPerServing,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'Meal Times'),
              _MealTimesSectionContent(
                mealStartHours: preferences.mealStartHours,
                notifier: notifier,
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'Allergens'),
              _AllergensSectionContent(
                selectedEntries: preferences.allergens,
                showRecipesWithAllergens: preferences.showRecipesWithAllergens,
                onShowRecipesWithAllergensChanged:
                    notifier.updateShowRecipesWithAllergens,
                notifier: notifier,
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'Notifications'),
              _SettingsCard(
                children: [
                  _SwitchRow(
                    icon: Icons.notifications_outlined,
                    label: 'Enable notifications',
                    value: preferences.notificationsEnabled,
                    onChanged: notifier.updateNotificationsEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(label: 'About'),
              _SettingsCard(
                children: [
                  _ActionRow(
                    icon: Icons.groups_2_outlined,
                    label: 'About Us',
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('About Us'),
                          content: const Text(
                            'NutriCook is built and maintained by the NutriCook development team.\n\nThanks for using the app.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.rosePink,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}


class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.12),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}


class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.rosePink.withValues(alpha: 0.1),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.rosePink),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppColors.rosePink;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: resolvedColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: resolvedColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: resolvedColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.rosePink),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Spacer(),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.rosePink,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SegmentRow<T> extends StatelessWidget {
  const _SegmentRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.rosePink),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Spacer(),
          SegmentedButton<T>(
            showSelectedIcon: false,
            selected: {value},
            onSelectionChanged: (sel) => onChanged(sel.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.rosePink,
              selectedForegroundColor: Colors.white,
              side: const BorderSide(color: AppColors.rosePink, width: 1.2),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            segments: options.entries
                .map(
                  (e) => ButtonSegment<T>(value: e.key, label: Text(e.value)),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CalorieGoalRow extends StatefulWidget {
  const _CalorieGoalRow({required this.current, required this.onChanged});
  final int current;
  final ValueChanged<int> onChanged;

  @override
  State<_CalorieGoalRow> createState() => _CalorieGoalRowState();
}

class _CalorieGoalRowState extends State<_CalorieGoalRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.current}');
  }

  @override
  void didUpdateWidget(_CalorieGoalRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current &&
        _controller.text != '${widget.current}') {
      _controller.text = '${widget.current}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 20,
            color: AppColors.rosePink,
          ),
          const SizedBox(width: 12),
          const Text(
            'Daily calorie goal',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Spacer(),
          SizedBox(
            width: 76,
            height: 36,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.rosePink,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cardRose.withValues(alpha: 0.4),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.rosePink.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.rosePink),
                ),
              ),
              onSubmitted: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed >= 100) {
                  widget.onChanged(parsed);
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'kcal',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTimesSectionContent extends StatelessWidget {
  const _MealTimesSectionContent({
    required this.mealStartHours,
    required this.notifier,
  });

  final Map<String, int> mealStartHours;
  final UserPreferencesNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final sanitizedHours = sanitizeMealStartHours(mealStartHours);

    return _SettingsCard(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Set the starting hour for each meal. Home and Planner will automatically use the current active meal time.',
            style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
          ),
        ),
        for (var i = 0; i < orderedMealTypes.length; i++) ...[
          _MealHourRow(
            mealType: orderedMealTypes[i],
            hour: sanitizedHours[orderedMealTypes[i]]!,
            onChanged: (hour) =>
                notifier.updateMealStartHour(orderedMealTypes[i], hour),
          ),
          if (i != orderedMealTypes.length - 1) const _Divider(),
        ],
      ],
    );
  }
}

class _MealHourRow extends StatelessWidget {
  const _MealHourRow({
    required this.mealType,
    required this.hour,
    required this.onChanged,
  });

  final String mealType;
  final int hour;
  final ValueChanged<int> onChanged;

  void _openHourPicker(BuildContext context) {
    final hourValues = List<int>.generate(12, (index) => index + 1);
    final periodValues = const <String>['AM', 'PM'];

    final initial12Hour = hour % 12 == 0 ? 12 : hour % 12;
    final initialHourIndex = hourValues.indexOf(initial12Hour);
    final initialPeriodIndex = hour >= 12 ? 1 : 0;

    var selectedHour12 = initial12Hour;
    var selectedPeriodIndex = initialPeriodIndex;

    final hourController = FixedExtentScrollController(
      initialItem: initialHourIndex,
    );
    final periodController = FixedExtentScrollController(
      initialItem: initialPeriodIndex,
    );

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 320,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          const Spacer(),
                          Text(
                            'Set $mealType Time',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              final isPm = selectedPeriodIndex == 1;
                              final nextHour = isPm
                                  ? (selectedHour12 % 12) + 12
                                  : (selectedHour12 % 12);
                              onChanged(nextHour);
                              Navigator.pop(ctx);
                            },
                            child: const Text(
                              'Done',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: hourController,
                              itemExtent: 38,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedHour12 = hourValues[index];
                                });
                              },
                              children: [
                                for (final value in hourValues)
                                  Center(
                                    child: Text(
                                      value.toString(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: periodController,
                              itemExtent: 38,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedPeriodIndex = index;
                                });
                              },
                              children: [
                                for (final value in periodValues)
                                  Center(
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 20,
            color: AppColors.rosePink,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${mealType} starts at ${formatMealHourLabel(hour)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _openHourPicker(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardRose.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.rosePink.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMealHourLabel(hour),
                    style: const TextStyle(
                      color: AppColors.rosePink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: 18,
                    color: AppColors.rosePink,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergensSectionContent extends ConsumerWidget {
  const _AllergensSectionContent({
    required this.selectedEntries,
    required this.showRecipesWithAllergens,
    required this.onShowRecipesWithAllergensChanged,
    required this.notifier,
  });

  final List<String> selectedEntries;
  final bool showRecipesWithAllergens;
  final ValueChanged<bool> onShowRecipesWithAllergensChanged;
  final UserPreferencesNotifier notifier;

  void _openCategoryPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IngredientAllergenPickerSheet(
        selectedEntries: selectedEntries,
        onChanged: notifier.updateAllergens,
      ),
    );
  }

  void _openIngredientPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddIngredientModal(
        onIngredientPicked: (ingredientId) {
          final normalizedEntry = allergenIngredientEntry(ingredientId);
          final updated = List<String>.from(selectedEntries)
            ..remove(ingredientId)
            ..remove(ingredientId.toLowerCase())
            ..add(normalizedEntry);
          notifier.updateAllergens(List<String>.from(updated.toSet()));
        },
      ),
    );
  }

  void _openDetails(
    BuildContext context, {
    required Map<String, String> ingredientNameMap,
    required Map<String, String> categoryNameMap,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllergenDetailsSheet(
        selectedEntries: selectedEntries,
        ingredientNameMap: ingredientNameMap,
        categoryNameMap: categoryNameMap,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients =
        ref.watch(ingredientsProvider).asData?.value ?? const [];
    final categories =
        ref.watch(ingredientCategoriesProvider).asData?.value ??
        const <String>[];
    final ingredientNameMap = {
      for (final ingredient in ingredients)
        ingredient.id.toLowerCase(): ingredient.name,
    };
    final categoryNameMap = {
      for (final category in categories) category.toLowerCase(): category,
    };
    final allergenCount = selectedEntries.toSet().length;

    return _SettingsCard(
      children: [
        _SwitchRow(
          icon: Icons.warning_amber_rounded,
          label: 'Show recipes with allergens',
          value: showRecipesWithAllergens,
          onChanged: onShowRecipesWithAllergensChanged,
        ),
        const _Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Recipes containing selected ingredients or whole ingredient categories will be flagged.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
        if (selectedEntries.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: selectedEntries.map((entry) {
                final label = _allergenEntryLabel(
                  entry,
                  ingredientNameMap: ingredientNameMap,
                  categoryNameMap: categoryNameMap,
                );
                return Chip(
                  label: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.cardRose.withValues(alpha: 0.5),
                  side: BorderSide(
                    color: AppColors.rosePink.withValues(alpha: 0.25),
                  ),
                  deleteIconColor: AppColors.rosePink,
                  onDeleted: () {
                    final updated = List<String>.from(selectedEntries)
                      ..remove(entry);
                    notifier.updateAllergens(updated);
                  },
                );
              }).toList(),
            ),
          ),
          const _Divider(),
        ],
        InkWell(
          onTap: () => _openIngredientPicker(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: AppColors.rosePink,
                ),
                SizedBox(width: 10),
                Text(
                  'Add Ingredient Allergen',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.rosePink,
                  ),
                ),
              ],
            ),
          ),
        ),
        const _Divider(),
        InkWell(
          onTap: () => _openCategoryPicker(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 20,
                  color: AppColors.rosePink,
                ),
                SizedBox(width: 10),
                Text(
                  'Manage Category Allergens',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.rosePink,
                  ),
                ),
              ],
            ),
          ),
        ),
        const _Divider(),
        InkWell(
          onTap: () => _openDetails(
            context,
            ingredientNameMap: ingredientNameMap,
            categoryNameMap: categoryNameMap,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.list_alt_rounded,
                  size: 20,
                  color: AppColors.rosePink,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Allergen Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.rosePink,
                    ),
                  ),
                ),
                Text(
                  '$allergenCount selected',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Ingredient picker bottom sheet ───────────────────────────────────────────

class _IngredientAllergenPickerSheet extends ConsumerStatefulWidget {
  const _IngredientAllergenPickerSheet({
    required this.selectedEntries,
    required this.onChanged,
  });

  final List<String> selectedEntries;
  final ValueChanged<List<String>> onChanged;

  @override
  ConsumerState<_IngredientAllergenPickerSheet> createState() =>
      _IngredientAllergenPickerSheetState();
}

class _IngredientAllergenPickerSheetState
    extends ConsumerState<_IngredientAllergenPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedEntries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(ingredientCategoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Allergen Categories',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.rosePink,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.rosePink,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.cardRose.withValues(alpha: 0.3),
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: AppColors.rosePink.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.rosePink),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (categories) {
                final filteredCategories = categories.where((category) {
                  if (_query.isEmpty) {
                    return true;
                  }
                  return category.toLowerCase().contains(_query);
                }).toList();

                if (filteredCategories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No categories found.',
                      style: TextStyle(color: Colors.black45),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 6),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.rosePink,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...filteredCategories.map((category) {
                      final entry = allergenCategoryEntry(category);
                      final isSelected = _selected.contains(entry);
                      return CheckboxListTile(
                        dense: true,
                        value: isSelected,
                        activeColor: AppColors.rosePink,
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          'Flags every ingredient in this category',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selected.add(entry);
                            } else {
                              _selected.remove(entry);
                            }
                          });
                          widget.onChanged(
                            List<String>.from(_selected.toSet()),
                          );
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergenDetailsSheet extends StatelessWidget {
  const _AllergenDetailsSheet({
    required this.selectedEntries,
    required this.ingredientNameMap,
    required this.categoryNameMap,
  });

  final List<String> selectedEntries;
  final Map<String, String> ingredientNameMap;
  final Map<String, String> categoryNameMap;

  @override
  Widget build(BuildContext context) {
    final uniqueEntries = selectedEntries.toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Text(
                  'Allergen Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  '${uniqueEntries.length} selected',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: uniqueEntries.isEmpty
                ? const Center(
                    child: Text(
                      'No allergens selected yet.',
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    itemBuilder: (context, index) {
                      final entry = uniqueEntries[index];
                      final isCategory = parseAllergenCategory(entry) != null;
                      final label = _allergenEntryLabel(
                        entry,
                        ingredientNameMap: ingredientNameMap,
                        categoryNameMap: categoryNameMap,
                      );
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        leading: Icon(
                          isCategory
                              ? Icons.category_outlined
                              : Icons.restaurant_menu_outlined,
                          size: 20,
                          color: AppColors.rosePink,
                        ),
                        title: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          isCategory
                              ? 'Category allergen'
                              : 'Ingredient allergen',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.rosePink.withValues(alpha: 0.08),
                    ),
                    itemCount: uniqueEntries.length,
                  ),
          ),
        ],
      ),
    );
  }
}

String _allergenEntryLabel(
  String entry, {
  required Map<String, String> ingredientNameMap,
  required Map<String, String> categoryNameMap,
}) {
  final category = parseAllergenCategory(entry);
  if (category != null) {
    final displayCategory = categoryNameMap[category] ?? category;
    return 'Category: $displayCategory';
  }

  final ingredientId = parseAllergenIngredientId(entry);
  if (ingredientId != null) {
    return ingredientNameMap[ingredientId] ?? ingredientId;
  }

  return entry;
}
