import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/admin/providers/admin_provider.dart';
import 'package:nutricook/features/admin/screens/edit_recipe_modal.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_report_provider.dart';
import 'package:nutricook/models/recipe_report/recipe_report.dart';

class AdminPanelPage extends ConsumerStatefulWidget {
  const AdminPanelPage({super.key});

  @override
  ConsumerState<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends ConsumerState<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _ingredientSearchController =
      TextEditingController();
  final TextEditingController _recipeSearchController = TextEditingController();
  String _query = '';
  String _ingredientQuery = '';
  String _recipeQuery = '';
  String _reportStatusFilter = '';
  int _openReportsCachedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    _ingredientSearchController.dispose();
    _recipeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isCurrentUserAdminProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(
          child: Text(
            'Access denied. Admin credentials are required.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final usersAsync = ref.watch(adminUsersQueryProvider(_query));
    final ingredientsAsync = ref.watch(adminIngredientsProvider(_ingredientQuery));
    final recipesAsync = ref.watch(adminRecipesProvider(_recipeQuery));
    final reportsAsync = ref.watch(adminReportsProvider(_reportStatusFilter));
    final openReportsAsync = ref.watch(adminReportsProvider('open'));
    final latestOpenReports = openReportsAsync.asData?.value.length;
    if (latestOpenReports != null) {
      _openReportsCachedCount = latestOpenReports;
    }
    final totalUsers = ref.watch(adminUsersCountProvider);
    final bannedUsers = ref.watch(adminBannedUsersCountProvider);
    final totalIngredients = ref.watch(adminIngredientsCountProvider);
    final totalRecipes = ref.watch(adminRecipesCountProvider);
    final openReports = latestOpenReports ?? _openReportsCachedCount;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.blushPink,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.rosePink,
          indicatorColor: AppColors.rosePink,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Reports'),
            Tab(text: 'Ingredients'),
            Tab(text: 'Recipes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(
            totalUsers: totalUsers,
            bannedUsers: bannedUsers,
            openReports: openReports,
            totalIngredients: totalIngredients,
            totalRecipes: totalRecipes,
          ),
          Column(
            children: [
              _buildSearchField(
                controller: _userSearchController,
                hintText: 'Search users by username/email',
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              Expanded(
                child: usersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Failed to load users: $error')),
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final userId = (user['id'] ?? '').toString();
                        final username = (user['username'] ?? 'Unknown').toString();
                        final email = (user['email'] ?? '').toString();
                        final role = (user['role'] ?? 'user').toString();
                        final isBanned = user['isBanned'] == true;
                        final isSelf = currentUserId == userId;

                        return _AdminCard(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.inputRose,
                                radius: 18,
                                child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                    if (email.isNotEmpty)
                                      Text(
                                        email,
                                        style: const TextStyle(color: Colors.black54),
                                      ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _ChipLabel(
                                          label: role.toUpperCase(),
                                          color: role.toLowerCase() == 'admin'
                                              ? AppColors.rosePink
                                              : Colors.grey.shade700,
                                        ),
                                        _ChipLabel(
                                          label: isBanned ? 'BANNED' : 'ACTIVE',
                                          color: isBanned ? Colors.red : Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                enabled: !isSelf,
                                onSelected: (value) async {
                                  if (isSelf) return;
                                  final service = ref.read(userServiceProvider);

                                  if (value == 'ban') {
                                    String reason = '';
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: const Text('Ban user'),
                                          content: TextField(
                                            decoration: const InputDecoration(
                                              hintText: 'Reason (optional)',
                                            ),
                                            onChanged: (v) => reason = v,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Ban'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed == true) {
                                      await service.setUserBanStatus(
                                        targetUserId: userId,
                                        isBanned: true,
                                        reason: reason,
                                        actionBy: currentUserId,
                                      );
                                    }
                                  }

                                  if (value == 'unban') {
                                    await service.setUserBanStatus(
                                      targetUserId: userId,
                                      isBanned: false,
                                      actionBy: currentUserId,
                                    );
                                  }

                                  if (value == 'promote') {
                                    await service.setUserRole(
                                      targetUserId: userId,
                                      role: 'admin',
                                    );
                                  }

                                  if (value == 'demote') {
                                    await service.setUserRole(
                                      targetUserId: userId,
                                      role: 'user',
                                    );
                                  }
                                },
                                itemBuilder: (_) => [
                                  if (!isBanned)
                                    const PopupMenuItem(
                                      value: 'ban',
                                      child: Text('Ban User'),
                                    ),
                                  if (isBanned)
                                    const PopupMenuItem(
                                      value: 'unban',
                                      child: Text('Unban User'),
                                    ),
                                  if (role.toLowerCase() != 'admin')
                                    const PopupMenuItem(
                                      value: 'promote',
                                      child: Text('Promote to Admin'),
                                    ),
                                  if (role.toLowerCase() == 'admin')
                                    const PopupMenuItem(
                                      value: 'demote',
                                      child: Text('Demote to User'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _statusFilterChip('All', ''),
                      const SizedBox(width: 8),
                      _statusFilterChip('Open', 'open'),
                      const SizedBox(width: 8),
                      _statusFilterChip('Reviewed', 'reviewed'),
                      const SizedBox(width: 8),
                      _statusFilterChip('Dismissed', 'dismissed'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: reportsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Failed to load reports: $error')),
                  data: (reports) {
                    if (reports.isEmpty) {
                      return const Center(child: Text('No reports yet.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                      itemCount: reports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _ReportCard(
                          report: report,
                          onStatusChanged: _setReportStatus,
                          onRecipeVisibilityChanged: _setRecipeVisibility,
                          statusColor: _statusColor,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              _buildSearchField(
                controller: _ingredientSearchController,
                hintText: 'Search ingredients by name/category',
                onChanged: (value) =>
                    setState(() => _ingredientQuery = value.trim()),
              ),
              Expanded(
                child: ingredientsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Failed to load ingredients: $error')),
                  data: (ingredients) {
                    if (ingredients.isEmpty) {
                      return const Center(child: Text('No ingredients found.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                      itemCount: ingredients.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final ingredient = ingredients[index];
                        final ingredientId =
                            (ingredient['id'] ?? '').toString();
                        final name =
                            (ingredient['name'] ?? 'Unnamed').toString();
                        final category =
                            (ingredient['category'] ?? 'Uncategorized')
                                .toString();
                        final description =
                            (ingredient['description'] ?? '').toString();
                        final ownerId = (ingredient['ownerId'] ?? '').toString();

                        return _AdminCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  _ChipLabel(
                                    label: ownerId.isEmpty
                                        ? 'SYSTEM'
                                        : 'CUSTOM',
                                    color: ownerId.isEmpty
                                        ? Colors.blueGrey
                                        : AppColors.rosePink,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Category: $category'),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.tonalIcon(
                                  onPressed: () => _showEditIngredientDialog(
                                    ingredientId: ingredientId,
                                    initialName: name,
                                    initialCategory: category,
                                    initialDescription: description,
                                  ),
                                  icon: const Icon(Icons.edit_rounded),
                                  label: const Text('Edit Ingredient'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              _buildSearchField(
                controller: _recipeSearchController,
                hintText: 'Search recipes by name/description',
                onChanged: (value) =>
                    setState(() => _recipeQuery = value.trim()),
              ),
              Expanded(
                child: recipesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Failed to load recipes: $error')),
                  data: (recipes) {
                    if (recipes.isEmpty) {
                      return const Center(child: Text('No recipes found.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                      itemCount: recipes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        final recipeId = (recipe['id'] ?? '').toString();
                        final name = (recipe['name'] ?? 'Untitled').toString();
                        final description =
                            (recipe['description'] ?? '').toString();
                        final isPublic = recipe['isPublic'] == true;
                        final reportCount =
                            (recipe['reportCount'] as num?)?.toInt() ?? 0;
                        final prepTime =
                            (recipe['prepTime'] as num?)?.toInt() ?? 0;
                        final cookTime =
                            (recipe['cookTime'] as num?)?.toInt() ?? 0;
                        final servings =
                            (recipe['servings'] as num?)?.toInt() ?? 1;

                        return _AdminCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  _ChipLabel(
                                    label: isPublic ? 'PUBLIC' : 'PRIVATE',
                                    color: isPublic ? Colors.green : Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (description.isNotEmpty)
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                'Prep: ${prepTime}m  |  Cook: ${cookTime}m  |  Servings: $servings  |  Reports: $reportCount',
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.tonalIcon(
                                  onPressed: () => _showEditRecipeDialog(
                                    recipeId: recipeId,
                                    initialName: name,
                                    initialDescription: description,
                                    initialPrepTime: prepTime,
                                    initialCookTime: cookTime,
                                    initialServings: servings,
                                    initialIsPublic: isPublic,
                                  ),
                                  icon: const Icon(Icons.edit_note_rounded),
                                  label: const Text('Edit Recipe'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppColors.rosePink),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.rosePink.withValues(alpha: 0.15),
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _statusFilterChip(String label, String statusValue) {
    final selected = _reportStatusFilter == statusValue;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.inputRose,
      onSelected: (_) {
        setState(() {
          _reportStatusFilter = statusValue;
        });
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'reviewed':
        return AppColors.rosePink;
      case 'dismissed':
        return Colors.grey;
      case 'open':
      default:
        return Colors.orange;
    }
  }

  Future<void> _setReportStatus({
    required String reportId,
    required String status,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    try {
      await ref.read(recipeReportServiceProvider).updateReportStatus(
            reportId: reportId,
            status: status,
            reviewedBy: currentUserId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report marked as $status.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update report: $error')),
      );
    }
  }

  Future<void> _setRecipeVisibility({
    required String recipeId,
    required bool isPublic,
  }) async {
    final action = isPublic ? 'unhide' : 'hide';
    try {
      await ref.read(recipeReportServiceProvider).setRecipeVisibility(
            recipeId: recipeId,
            isPublic: isPublic,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe ${action}d successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to $action recipe: $error')),
      );
    }
  }

  Future<void> _showEditIngredientDialog({
    required String ingredientId,
    required String initialName,
    required String initialCategory,
    required String initialDescription,
  }) async {
    final nameController = TextEditingController(text: initialName);
    final categoryController = TextEditingController(text: initialCategory);
    final descriptionController = TextEditingController(text: initialDescription);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Ingredient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    final name = nameController.text.trim();
    final category = categoryController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || category.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and category are required.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.ingredients)
          .doc(ingredientId)
          .update(<String, dynamic>{
            'name': name,
            'category': category,
            'description': description,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredient updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update ingredient: $error')),
      );
    }
  }

  Future<void> _showEditRecipeDialog({
    required String recipeId,
    required String initialName,
    required String initialDescription,
    required int initialPrepTime,
    required int initialCookTime,
    required int initialServings,
    required bool initialIsPublic,
  }) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditRecipeModal(
        recipeId: recipeId,
        initialName: initialName,
        initialDescription: initialDescription,
        initialPrepTime: initialPrepTime,
        initialCookTime: initialCookTime,
        initialServings: initialServings,
        initialIsPublic: initialIsPublic,
      ),
    );
  }

}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.totalUsers,
    required this.bannedUsers,
    required this.openReports,
    required this.totalIngredients,
    required this.totalRecipes,
  });

  final int totalUsers;
  final int bannedUsers;
  final int openReports;
  final int totalIngredients;
  final int totalRecipes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MetricCard(title: 'Total Users', value: '$totalUsers'),
        const SizedBox(height: 10),
        _MetricCard(title: 'Banned Users', value: '$bannedUsers'),
        const SizedBox(height: 10),
        _MetricCard(title: 'Open Reports', value: '$openReports'),
        const SizedBox(height: 10),
        _MetricCard(title: 'Ingredients', value: '$totalIngredients'),
        const SizedBox(height: 10),
        _MetricCard(title: 'Recipes', value: '$totalRecipes'),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.14)),
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.rosePink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({
    required this.report,
    required this.onStatusChanged,
    required this.onRecipeVisibilityChanged,
    required this.statusColor,
  });

  final RecipeReport report;
  final Function(
      {required String reportId,
      required String status}) onStatusChanged;
  final Function({required String recipeId, required bool isPublic})
      onRecipeVisibilityChanged;
  final Color Function(String) statusColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch recipe name using the stable provider
    final recipeAsync = ref.watch(adminRecipeNameProvider(report.recipeId));

    // Fetch reporter name
    final reporterNameAsync = ref.watch(userDataByIdProvider(report.reporterId));

    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Report Reason and Status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Reason',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.reason,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ChipLabel(
                label: report.status.toUpperCase(),
                color: statusColor(report.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),
          const SizedBox(height: 14),

          // Recipe Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipe',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              recipeAsync.when(
                loading: () => Text(
                  'Loading...',
                  style: TextStyle(color: Colors.black54),
                ),
                error: (_, __) => Text(
                  'Error loading recipe',
                  style: TextStyle(color: Colors.black54),
                ),
                data: (recipeName) {
                  final displayName =
                      recipeName ?? 'Unknown Recipe (${report.recipeId})';
                  return Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reporter Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reporter',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              reporterNameAsync.when(
                loading: () => Text(
                  'Loading...',
                  style: TextStyle(color: Colors.black54),
                ),
                error: (_, __) => Text(
                  'Unknown User (${report.reporterId})',
                  style: TextStyle(color: Colors.black54),
                ),
                data: (reporterData) {
                  final reporterName =
                      reporterData?['username'] ?? 'Unknown User';
                  return Text(
                    reporterName.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Submission Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submitted',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(
                        report.createdAt.toLocal(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Details if available
          if ((report.details ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  report.details!,
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),
          const SizedBox(height: 12),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: report.status == 'open'
                    ? null
                    : () => onStatusChanged(
                          reportId: report.id,
                          status: 'open',
                        ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reopen'),
              ),
              OutlinedButton.icon(
                onPressed: report.status == 'reviewed'
                    ? null
                    : () => onStatusChanged(
                          reportId: report.id,
                          status: 'reviewed',
                        ),
                icon: const Icon(Icons.task_alt),
                label: const Text('Mark Reviewed'),
              ),
              OutlinedButton.icon(
                onPressed: report.status == 'dismissed'
                    ? null
                    : () => onStatusChanged(
                          reportId: report.id,
                          status: 'dismissed',
                        ),
                icon: const Icon(Icons.gpp_good),
                label: const Text('Dismiss'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => onRecipeVisibilityChanged(
                  recipeId: report.recipeId,
                  isPublic: false,
                ),
                icon: const Icon(Icons.visibility_off),
                label: const Text('Hide Recipe'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => onRecipeVisibilityChanged(
                  recipeId: report.recipeId,
                  isPublic: true,
                ),
                icon: const Icon(Icons.visibility),
                label: const Text('Unhide Recipe'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

