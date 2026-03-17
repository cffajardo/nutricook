import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/admin/providers/admin_provider.dart';
import 'package:nutricook/features/admin/screens/edit_recipe_modal.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_report_provider.dart';
import 'package:nutricook/models/recipe_report/recipe_report.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/services/archive_service.dart';
import 'package:nutricook/services/notification_trigger.dart';
import 'package:nutricook/core/constants.dart';

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
  String _ingredientSortBy = 'name_asc'; // name_asc, name_desc
  String _ingredientFilterCategory = ''; // '', or specific category name
  String _recipeSortBy = 'name_asc'; // name_asc, name_desc, reports, favorites
  String _recipeFilterVisibility = ''; // '', 'public', 'private'
  int _openReportsCachedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _userSearchController.clear();
      _ingredientSearchController.clear();
      _recipeSearchController.clear();
      // Also clear the internal query strings to reset providers
      setState(() {
        _query = '';
        _ingredientQuery = '';
        _recipeQuery = '';
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
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
        backgroundColor: const Color(0xFFFFF9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF9FA),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.rosePink, size: 32),
            onPressed: () => context.pop(),
          ),
          title: const Text('Admin Console', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: Text(
            'Access denied. Admin credentials required.',
            style: TextStyle(fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFF9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.rosePink, size: 32),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.rosePink,
          unselectedLabelColor: Colors.black45,
          indicatorColor: AppColors.rosePink,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Reports'),
            Tab(text: 'Ingredients'),
            Tab(text: 'Recipes'),
            Tab(text: 'Archive'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. OVERVIEW TAB
          _OverviewTab(
            totalUsers: totalUsers,
            bannedUsers: bannedUsers,
            openReports: openReports,
            totalIngredients: totalIngredients,
            totalRecipes: totalRecipes,
          ),
          
          // 2. USERS TAB
          Column(
            children: [
              _buildSearchField(
                controller: _userSearchController,
                hintText: 'Search username or email...',
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              Expanded(
                child: usersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
                  error: (error, _) => Center(child: Text('Failed to load users: $error')),
                  data: (users) {
                    if (users.isEmpty) return const Center(child: Text('No users found.'));

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                                backgroundColor: AppColors.cardRose,
                                radius: 24,
                                child: Text(
                                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.rosePink, fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    if (email.isNotEmpty)
                                      Text(
                                        email,
                                        style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _ChipLabel(
                                          label: role.toUpperCase(),
                                          color: role.toLowerCase() == 'admin' ? AppColors.rosePink : Colors.blueGrey,
                                        ),
                                        if (isBanned)
                                          const _ChipLabel(label: 'BANNED', color: Colors.redAccent)
                                        else
                                          const _ChipLabel(label: 'ACTIVE', color: Colors.green),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                enabled: !isSelf,
                                icon: const Icon(Icons.more_vert, color: Colors.black45),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                onSelected: (value) async {
                                  if (isSelf) return;
                                  final service = ref.read(userServiceProvider);

                                  if (value == 'ban') {
                                    String reason = '';
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: const Text('Ban user', style: TextStyle(fontWeight: FontWeight.bold)),
                                        content: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Reason (optional)',
                                            filled: true,
                                            fillColor: AppColors.cardRose.withValues(alpha: 0.3),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          onChanged: (v) => reason = v,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                                            child: const Text('Ban'),
                                          ),
                                        ],
                                      ),
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
                                    await service.setUserBanStatus(targetUserId: userId, isBanned: false, actionBy: currentUserId);
                                  }

                                  if (value == 'promote') {
                                    await service.setUserRole(targetUserId: userId, role: 'admin');
                                  }

                                  if (value == 'demote') {
                                    await service.setUserRole(targetUserId: userId, role: 'user');
                                  }
                                },
                                itemBuilder: (_) => [
                                  if (!isBanned)
                                    const PopupMenuItem(value: 'ban', child: Text('Ban User', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                                  if (isBanned)
                                    const PopupMenuItem(value: 'unban', child: Text('Unban User', style: TextStyle(fontWeight: FontWeight.bold))),
                                  if (role.toLowerCase() != 'admin')
                                    const PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                                  if (role.toLowerCase() == 'admin')
                                    const PopupMenuItem(value: 'demote', child: Text('Demote to User')),
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
          
          // 3. REPORTS TAB
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _statusFilterChip('All Reports', ''),
                      const SizedBox(width: 8),
                      _statusFilterChip('Open', 'open'),
                      const SizedBox(width: 8),
                      _statusFilterChip('Archived', 'archived'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: reportsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
                  error: (error, _) => Center(child: Text('Failed to load reports: $error')),
                  data: (reports) {
                    if (reports.isEmpty) return const Center(child: Text('No reports found.'));

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: reports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _ReportCard(
                          report: reports[index],
                          onStatusChanged: _setReportStatus,
                          onRecipeDeleted: _deleteRecipe,
                          onReportDeleted: _deleteReport,
                          statusColor: _statusColor,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          
          // 4. INGREDIENTS TAB
          Column(
            children: [
              _buildSearchField(
                controller: _ingredientSearchController,
                hintText: 'Search ingredients...',
                onChanged: (value) => setState(() => _ingredientQuery = value.trim()),
              ),
              Expanded(
                child: ingredientsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
                  error: (error, _) => Center(child: Text('Failed to load ingredients: $error')),
                  data: (ingredients) {
                    // Get unique categories for dynamic filter dropdown
                    final categories = ingredients
                        .map((i) => ((i['category'] ?? 'Uncategorized').toString()))
                        .toSet()
                        .toList()
                        .cast<String>()
                        ..sort();

                    // Apply filtering
                    var filtered = ingredients.where((ingredient) {
                      final category = (ingredient['category'] ?? 'Uncategorized').toString();
                      if (_ingredientFilterCategory.isEmpty) return true;
                      return category == _ingredientFilterCategory;
                    }).toList();

                    // Apply sorting
                    filtered.sort((a, b) {
                      switch (_ingredientSortBy) {
                        case 'name_desc':
                          return ((b['name'] ?? '').toString())
                              .compareTo(((a['name'] ?? '').toString()));
                        case 'name_asc':
                        default:
                          return ((a['name'] ?? '').toString())
                              .compareTo(((b['name'] ?? '').toString()));
                      }
                    });

                    if (filtered.isEmpty) return const Center(child: Text('No ingredients found.'));

                    return Column(
                      children: [
                        // Sort and Filter Controls
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _ingredientSortBy,
                                  isExpanded: true,
                                  hint: const Text('Sort by'),
                                  items: const [
                                    DropdownMenuItem(value: 'name_asc', child: Text('Name A-Z')),
                                    DropdownMenuItem(value: 'name_desc', child: Text('Name Z-A')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _ingredientSortBy = value);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _ingredientFilterCategory,
                                  isExpanded: true,
                                  hint: const Text('Filter by Category'),
                                  items: [
                                    const DropdownMenuItem(value: '', child: Text('All')),
                                    ...categories.map((cat) => 
                                      DropdownMenuItem(value: cat, child: Text(cat)),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _ingredientFilterCategory = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final ingredient = filtered[index];
                              final ingredientId = (ingredient['id'] ?? '').toString();
                              final name = (ingredient['name'] ?? 'Unnamed').toString();
                              final category = (ingredient['category'] ?? 'Uncategorized').toString();
                              final description = (ingredient['description'] ?? '').toString();
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
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        _ChipLabel(
                                          label: ownerId.isEmpty ? 'SYSTEM' : 'CUSTOM',
                                          color: ownerId.isEmpty ? Colors.blueGrey : AppColors.rosePink,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Category: $category', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                                    if (description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(description, style: const TextStyle(color: Colors.black54)),
                                    ],
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          context.pushNamed(
                                            AppRoutes.adminEditIngredientName,
                                            pathParameters: {'ingredientId': ingredientId},
                                          );
                                        },
                                        icon: const Icon(Icons.edit_rounded, size: 18),
                                        label: const Text('Edit Ingredient'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.rosePink,
                                          side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.3), width: 1.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          
          // 5. RECIPES TAB
          Column(
            children: [
              _buildSearchField(
                controller: _recipeSearchController,
                hintText: 'Search recipes...',
                onChanged: (value) => setState(() => _recipeQuery = value.trim()),
              ),
              // Sort and Filter Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _recipeSortBy,
                        isExpanded: true,
                        hint: const Text('Sort by'),
                        items: const [
                          DropdownMenuItem(value: 'name_asc', child: Text('Name A-Z')),
                          DropdownMenuItem(value: 'name_desc', child: Text('Name Z-A')),
                          DropdownMenuItem(value: 'reports', child: Text('Reports')),
                          DropdownMenuItem(value: 'favorites', child: Text('Favorites')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _recipeSortBy = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _recipeFilterVisibility,
                        isExpanded: true,
                        hint: const Text('Filter'),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('All')),
                          DropdownMenuItem(value: 'public', child: Text('Public')),
                          DropdownMenuItem(value: 'private', child: Text('Private')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _recipeFilterVisibility = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: recipesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
                  error: (error, _) => Center(child: Text('Failed to load recipes: $error')),
                  data: (recipes) {
                    // Apply filtering
                    var filtered = recipes.where((recipe) {
                      final isPublic = recipe['isPublic'] == true;
                      if (_recipeFilterVisibility.isEmpty) return true;
                      if (_recipeFilterVisibility == 'public') return isPublic;
                      if (_recipeFilterVisibility == 'private') return !isPublic;
                      return true;
                    }).toList();

                    // Apply sorting
                    filtered.sort((a, b) {
                      switch (_recipeSortBy) {
                        case 'name_desc':
                          return ((b['name'] ?? '').toString())
                              .compareTo(((a['name'] ?? '').toString()));
                        case 'reports':
                          final aReports = (a['reportCount'] as num?)?.toInt() ?? 0;
                          final bReports = (b['reportCount'] as num?)?.toInt() ?? 0;
                          return bReports.compareTo(aReports); // Descending
                        case 'favorites':
                          final aFavorite = (a['isFavorite'] ?? false) == true ? 1 : 0;
                          final bFavorite = (b['isFavorite'] ?? false) == true ? 1 : 0;
                          return bFavorite.compareTo(aFavorite); // Favorites first
                        case 'name_asc':
                        default:
                          return ((a['name'] ?? '').toString())
                              .compareTo(((b['name'] ?? '').toString()));
                      }
                    });

                    if (filtered.isEmpty) return const Center(child: Text('No recipes found.'));

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final recipe = filtered[index];
                        final recipeId = (recipe['id'] ?? '').toString();
                        final name = (recipe['name'] ?? 'Untitled').toString();
                        final description = (recipe['description'] ?? '').toString();
                        final isPublic = recipe['isPublic'] == true;
                        final reportCount = (recipe['reportCount'] as num?)?.toInt() ?? 0;
                        final prepTime = (recipe['prepTime'] as num?)?.toInt() ?? 0;
                        final cookTime = (recipe['cookTime'] as num?)?.toInt() ?? 0;
                        final servings = (recipe['servings'] as num?)?.toInt() ?? 1;

                        return _AdminCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  _ChipLabel(
                                    label: isPublic ? 'PUBLIC' : 'PRIVATE',
                                    color: isPublic ? Colors.green : Colors.blueGrey,
                                  ),
                                  if (recipe['archived'] == true) ...[
                                    const SizedBox(width: 8),
                                    const _ChipLabel(label: 'ARCHIVED', color: AppColors.rosePink),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (description.isNotEmpty)
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _ChipLabel(label: '${prepTime + cookTime}m total', color: Colors.black54),
                                  _ChipLabel(label: '$servings servings', color: Colors.black54),
                                  if (reportCount > 0)
                                    _ChipLabel(label: '$reportCount Reports', color: Colors.orange),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showEditRecipeDialog(
                                    recipeId: recipeId,
                                    initialName: name,
                                    initialDescription: description,
                                    initialPrepTime: prepTime,
                                    initialCookTime: cookTime,
                                    initialServings: servings,
                                    initialIsPublic: isPublic,
                                  ),
                                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                                  label: const Text('Edit Recipe'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.rosePink,
                                    side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.3), width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
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
          
          // 6. ARCHIVE TAB
          _ArchiveTab(
            recipeQuery: _recipeQuery,
            recipeSortBy: _recipeSortBy,
            showEditRecipeDialog: _showEditRecipeDialog,
            onReportStatusChanged: _setReportStatus,
            onRecipeDeleted: _deleteRecipe,
            onReportDeleted: _deleteReport,
            statusColor: _statusColor,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppColors.rosePink),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38),
          filled: true,
          fillColor: AppColors.cardRose.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.all(16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.15), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
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
      showCheckmark: false,
      selectedColor: AppColors.rosePink,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppColors.rosePink : Colors.black12,
        width: 1.5,
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black54,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => setState(() => _reportStatusFilter = statusValue),
    );
  }

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'reviewed':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      case 'archived':
        return AppColors.rosePink;
      case 'resolved': // Hypothetical if we ever use it
        return Colors.blue;
      case 'open':
      default:
        return Colors.orange;
    }
  }

  Future<void> _setReportStatus({required String reportId, required String status}) async {
    final currentUserId = ref.read(currentUserIdProvider);
    String finalStatus = status;
    String? note;

    // Based on user feedback: Reviewed and Dismissed reports should be ARCHIVED after processing.
    if (status == 'reviewed' || status == 'dismissed') {
      finalStatus = 'archived';
      note = status == 'reviewed' ? 'Marked as Reviewed' : 'Marked as Dismissed';
    }

    try {
      await ref.read(recipeReportServiceProvider).updateReportStatus(
            reportId: reportId,
            status: finalStatus,
            reviewedBy: currentUserId,
            reviewNote: note,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report processed and archived.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update report: $error')));
    }
  }

  Future<void> _deleteReport({required String reportId}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to permanently delete this report? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(recipeReportServiceProvider).deleteReport(reportId: reportId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report permanently deleted.')));
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete report: $error')));
      }
    }
  }

  Future<void> _deleteRecipe({
    required String recipeId,
    required String recipeName,
    required String recipeOwnerId,
    required String reason,
  }) async {
    try {
      // Fetch owner's FCM token
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipeOwnerId)
          .get();
      
      final ownerFcmToken = userDoc.data()?['fcmToken'] as String?;
  
      // Archive the recipe instead of deleting
      await ref.read(archiveServiceProvider).archiveItem(
            collection: AppConstants.collectionRecipes,
            docId: recipeId,
          );
      
      // Update ALL reports for this recipe to 'archived' status
      final reportsSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.recipeReports)
          .where('recipeId', isEqualTo: recipeId)
          .get();
      
      final currentUserId = ref.read(currentUserIdProvider);
      final reportService = ref.read(recipeReportServiceProvider);
      
      for (final doc in reportsSnapshot.docs) {
        await reportService.updateReportStatus(
          reportId: doc.id,
          status: 'archived',
          reviewedBy: currentUserId,
          reviewNote: 'Archived by admin. Reason: $reason',
        );
      }
  
      if (ownerFcmToken != null && ownerFcmToken.isNotEmpty) {
        await NotificationTrigger.sendRecipeDeletedNotification(
          recipeId: recipeId,
          recipeName: recipeName,
          recipeOwnerId: recipeOwnerId,
          ownerFcmToken: ownerFcmToken,
          reason: reason,
        );
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe moved to archive.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to archive recipe: $error')));
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.rosePink),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2, // Makes them nice square-ish dashboard cards
            children: [
              _MetricCard(title: 'Total Users', value: '$totalUsers', icon: Icons.people_alt_rounded),
              _MetricCard(title: 'Banned Users', value: '$bannedUsers', icon: Icons.gavel_rounded, isAlert: bannedUsers > 0),
              _MetricCard(title: 'Open Reports', value: '$openReports', icon: Icons.flag_rounded, isAlert: openReports > 0),
              _MetricCard(title: 'Total Recipes', value: '$totalRecipes', icon: Icons.restaurant_menu_rounded),
            ],
          ),
          const SizedBox(height: 16),
          // Span the last metric across the full width
          SizedBox(
            width: double.infinity,
            height: 120,
            child: _MetricCard(title: 'Total Ingredients', value: '$totalIngredients', icon: Icons.eco_rounded),
          )
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.14), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon, this.isAlert = false});

  final String title;
  final String value;
  final IconData icon;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final color = isAlert ? Colors.orange : AppColors.rosePink;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.14), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color.withValues(alpha: 0.5), size: 28),
              Text(
                value,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({
    required this.report,
    required this.onStatusChanged,
    required this.onRecipeDeleted,
    required this.onReportDeleted,
    required this.statusColor,
  });

  final RecipeReport report;
  final Function({required String reportId, required String status}) onStatusChanged;
  final Function({
    required String recipeId,
    required String recipeName,
    required String recipeOwnerId,
    required String reason,
  }) onRecipeDeleted;
  final Function({required String reportId}) onReportDeleted;
  final Color Function(String) statusColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDataAsync = ref.watch(adminRecipeDataProvider(report.recipeId));
    final reporterNameAsync = ref.watch(userDataByIdProvider(report.reporterId));

    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Report Reason and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REASON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45)),
                    const SizedBox(height: 2),
                    Text(
                      report.reason,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              _ChipLabel(
                label: report.status.toUpperCase(),
                color: statusColor(report.status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Details Box (if provided)
          if ((report.details ?? '').isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardRose.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report.details!,
                style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Meta Info Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RECIPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45)),
                    const SizedBox(height: 2),
                    recipeDataAsync.when(
                      loading: () => const Text('Loading...', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      error: (_, _) => const Text('Error', style: TextStyle(color: Colors.red, fontSize: 13)),
                      data: (data) => Text(
                        data.name ?? 'Unknown (${report.recipeId})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REPORTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45)),
                    const SizedBox(height: 2),
                    reporterNameAsync.when(
                      loading: () => const Text('Loading...', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      error: (_, _) => const Text('Unknown User', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      data: (data) => Text(
                        (data?['username'] ?? 'Unknown User').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Submitted: ${DateFormat('MMM dd, yyyy HH:mm').format(report.createdAt.toLocal())}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black45),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (report.status == 'archived') ...[
                OutlinedButton.icon(
                  onPressed: () => onStatusChanged(reportId: report.id, status: 'open'),
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Reopen', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => onReportDeleted(reportId: report.id),
                  icon: const Icon(Icons.delete_forever_rounded, size: 18),
                  label: const Text('Delete Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ] else ...[
                if (report.status != 'open')
                  OutlinedButton(
                    onPressed: () => onStatusChanged(reportId: report.id, status: 'open'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reopen', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                if (report.status != 'reviewed')
                  FilledButton.tonal(
                    onPressed: () => onStatusChanged(reportId: report.id, status: 'reviewed'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      foregroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Mark Reviewed', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                if (report.status != 'dismissed')
                  FilledButton.tonal(
                    onPressed: () => onStatusChanged(reportId: report.id, status: 'dismissed'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ],
          ),
          if (report.status != 'archived') ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: recipeDataAsync.when(
                loading: () => FilledButton.tonal(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Delete Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                error: (_, _) => FilledButton.tonal(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Delete Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                data: (recipeData) => FilledButton.tonal(
                  onPressed: () => onRecipeDeleted(
                    recipeId: report.recipeId,
                    recipeName: recipeData.name ?? 'Unknown Recipe',
                    recipeOwnerId: recipeData.ownerId ?? 'unknown',
                    reason: report.reason,
                  ),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Delete Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArchiveTab extends ConsumerStatefulWidget {
  const _ArchiveTab({
    required this.recipeQuery,
    required this.recipeSortBy,
    required this.showEditRecipeDialog,
    required this.onReportStatusChanged,
    required this.onRecipeDeleted,
    required this.onReportDeleted,
    required this.statusColor,
  });

  final String recipeQuery;
  final String recipeSortBy;
  final Function({
    required String recipeId,
    required String initialName,
    required String initialDescription,
    required int initialPrepTime,
    required int initialCookTime,
    required int initialServings,
    required bool initialIsPublic,
  }) showEditRecipeDialog;
  final Function({required String reportId, required String status}) onReportStatusChanged;
  final Function({
    required String recipeId,
    required String recipeName,
    required String recipeOwnerId,
    required String reason,
  }) onRecipeDeleted;
  final Function({required String reportId}) onReportDeleted;
  final Color Function(String) statusColor;

  @override
  ConsumerState<_ArchiveTab> createState() => _ArchiveTabState();
}

class _ArchiveTabState extends ConsumerState<_ArchiveTab> {
  String _archiveType = 'recipes'; // 'recipes' or 'reports'

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'recipes', label: Text('Recipes'), icon: Icon(Icons.restaurant_menu)),
              ButtonSegment(value: 'reports', label: Text('Reports'), icon: Icon(Icons.flag)),
            ],
            selected: {_archiveType},
            onSelectionChanged: (value) => setState(() => _archiveType = value.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.rosePink.withValues(alpha: 0.1),
              selectedForegroundColor: AppColors.rosePink,
            ),
          ),
        ),
        Expanded(
          child: _archiveType == 'recipes' ? _buildArchivedRecipes() : _buildArchivedReports(),
        ),
      ],
    );
  }

  Widget _buildArchivedRecipes() {
    final archivedRecipesAsync = ref.watch(adminArchivedRecipesProvider(widget.recipeQuery));

    return archivedRecipesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
      error: (error, _) => Center(child: Text('Failed to load archived recipes: $error')),
      data: (recipes) {
        if (recipes.isEmpty) return const Center(child: Text('No archived recipes found.'));

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          physics: const BouncingScrollPhysics(),
          itemCount: recipes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            final recipeId = recipe['id'].toString();
            final name = (recipe['name'] ?? 'Untitled').toString();
            final prepTime = (recipe['prepTime'] as num?)?.toInt() ?? 0;
            final cookTime = (recipe['cookTime'] as num?)?.toInt() ?? 0;

            return _AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const _ChipLabel(label: 'ARCHIVED', color: AppColors.rosePink),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Total Time: ${prepTime + cookTime}m', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _restoreRecipe(recipeId),
                          icon: const Icon(Icons.restore_rounded, size: 18),
                          label: const Text('Restore'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _permanentlyDeleteRecipe(recipeId),
                          icon: const Icon(Icons.delete_forever_rounded, size: 18),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArchivedReports() {
    final archivedReportsAsync = ref.watch(adminReportsProvider('archived'));

    return archivedReportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.rosePink)),
      error: (error, _) => Center(child: Text('Failed to load archived reports: $error')),
      data: (reports) {
        if (reports.isEmpty) return const Center(child: Text('No archived reports found.'));

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          physics: const BouncingScrollPhysics(),
          itemCount: reports.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            return _ReportCard(
              report: report,
              onStatusChanged: widget.onReportStatusChanged,
              onRecipeDeleted: widget.onRecipeDeleted,
              onReportDeleted: widget.onReportDeleted,
              statusColor: widget.statusColor,
            );
          },
        );
      },
    );
  }

  Future<void> _restoreRecipe(String recipeId) async {
    try {
      await ref.read(archiveServiceProvider).restoreItem(
        collection: AppConstants.collectionRecipes,
        docId: recipeId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe restored.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error restoring recipe: $e')));
    }
  }

  Future<void> _permanentlyDeleteRecipe(String recipeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permanent Delete'),
        content: const Text('Are you sure you want to permanently delete this recipe? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(archiveServiceProvider).permanentlyDeleteItem(
          collection: AppConstants.collectionRecipes,
          docId: recipeId,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe permanently deleted.')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting recipe: $e')));
      }
    }
  }
}