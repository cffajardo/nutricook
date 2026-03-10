import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/collection/provider/collection_provider.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_card.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/user_preferences/user_preferences.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool _isFollowActionLoading = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authProvider).signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _showSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _ProfileSettingsSheet(),
    );
  }

  Future<void> _toggleFollow({
    required bool isFollowing,
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (_isFollowActionLoading) return;

    setState(() => _isFollowActionLoading = true);
    try {
      final userService = ref.read(userServiceProvider);
      if (isFollowing) {
        await userService.unfollowUser(
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        );
      } else {
        await userService.followUser(
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed to update follow state: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isFollowActionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final viewedUserId = widget.userId ?? currentUserId;

    if (viewedUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Sign in to view profile.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final isOwnProfile = currentUserId == viewedUserId;

    final userDataAsync = isOwnProfile
        ? ref.watch(userDataProvider)
        : ref.watch(userDataByIdProvider(viewedUserId));

    final userRecipesAsync = isOwnProfile
        ? ref.watch(userRecipesProvider)
        : ref.watch(userRecipesByOwnerProvider(viewedUserId));

    final userCollectionsAsync = isOwnProfile
        ? ref.watch(userCollectionsProvider)
        : ref.watch(userCollectionsByOwnerProvider(viewedUserId));

    final followingIds =
        ref.watch(userFollowingIdsProvider).asData?.value ?? const <String>[];
    final isFollowing = followingIds.contains(viewedUserId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        actions: [
          if (isOwnProfile)
            IconButton(
              onPressed: _showSettingsSheet,
              icon: const Icon(Icons.settings_outlined, color: Colors.black),
            ),
        ],
      ),
      body: userDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load profile: $error',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        data: (userData) {
          if (userData == null) {
            return const Center(
              child: Text(
                'Profile unavailable. Please sign in again.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          final recipeCount = userRecipesAsync.asData?.value.length ?? 0;
          final collectionCount =
              userCollectionsAsync.asData?.value.length ?? 0;

          return Column(
            children: [
              _buildProfileHeader(
                userData: userData,
                recipeCount: recipeCount,
                collectionCount: collectionCount,
                isOwnProfile: isOwnProfile,
                isFollowing: isFollowing,
                canFollow: !isOwnProfile && currentUserId != null,
                onToggleFollow: () => _toggleFollow(
                  isFollowing: isFollowing,
                  currentUserId: currentUserId!,
                  targetUserId: viewedUserId,
                ),
              ),

              TabBar(
                controller: tabController,
                indicatorColor: AppColors.rosePink,
                indicatorWeight: 3,
                labelColor: AppColors.rosePink,
                unselectedLabelColor: Colors.black26,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Recipes'),
                  Tab(text: 'Collections'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    _buildRecipeGrid(userRecipesAsync),
                    _buildCollectionsTab(userCollectionsAsync),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader({
    required Map<String, dynamic> userData,
    required int recipeCount,
    required int collectionCount,
    required bool isOwnProfile,
    required bool isFollowing,
    required bool canFollow,
    required VoidCallback onToggleFollow,
  }) {
    final username = (userData['username'] ?? 'Chef').toString();
    final email = (userData['email'] ?? '').toString();
    final followers = List<String>.from(
      userData['followers'] ?? const <String>[],
    );
    final following = List<String>.from(
      userData['following'] ?? const <String>[],
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.rosePink, width: 2),
            ),
            child: const CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.cardRose,
              child: Icon(Icons.person, size: 40, color: AppColors.rosePink),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          if (email.isNotEmpty)
            Text(
              email,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('$recipeCount', 'Recipes'),
              _buildStatItem('${followers.length}', 'Followers'),
              _buildStatItem('${following.length}', 'Following'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$collectionCount collections',
            style: const TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isOwnProfile
                  ? _signOut
                  : canFollow && !_isFollowActionLoading
                  ? onToggleFollow
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOwnProfile
                    ? Colors.white
                    : isFollowing
                    ? Colors.white
                    : AppColors.rosePink,
                elevation: 0,
                side: BorderSide(
                  color: isOwnProfile
                      ? Colors.black12
                      : isFollowing
                      ? Colors.black12
                      : AppColors.rosePink,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isOwnProfile
                    ? 'Sign Out'
                    : _isFollowActionLoading
                    ? 'Working...'
                    : isFollowing
                    ? 'Following'
                    : 'Follow',
                style: TextStyle(
                  color: isOwnProfile || isFollowing
                      ? Colors.black54
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeGrid(AsyncValue<List<Recipe>> userRecipesAsync) {
    return userRecipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(
            child: Text(
              'No recipes yet',
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: recipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return RecipeCard(recipe: recipe);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Failed to load recipes: $error',
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildCollectionsTab(
    AsyncValue<List<Collection>> userCollectionsAsync,
  ) {
    return userCollectionsAsync.when(
      data: (collections) {
        if (collections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.collections_bookmark_outlined,
                  size: 64,
                  color: AppColors.rosePink.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No collections yet',
                  style: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: collections.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final collection = collections[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.rosePink.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  if (collection.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      collection.description,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${collection.recipeCount} recipes',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Failed to load collections: $error',
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

class _ProfileSettingsSheet extends ConsumerWidget {
  const _ProfileSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(userPreferencesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: preferencesAsync.when(
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Failed to load settings: $error',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
          data: (preferences) {
            final notifier = ref.read(userPreferencesProvider.notifier);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile settings',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 14),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Notifications'),
                  value: preferences.notificationsEnabled,
                  activeThumbColor: AppColors.rosePink,
                  onChanged: notifier.updateNotificationsEnabled,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Only verified recipes'),
                  value: preferences.showOnlyVerifiedRecipes,
                  activeThumbColor: AppColors.rosePink,
                  onChanged: notifier.updateShowOnlyVerifiedRecipes,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Nutrition per serving'),
                  value: preferences.showNutritionPerServing,
                  activeThumbColor: AppColors.rosePink,
                  onChanged: notifier.updateShowNutritionPerServing,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Unit system',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    SegmentedButton<UnitSystem>(
                      showSelectedIcon: false,
                      selected: {preferences.unitSystem},
                      onSelectionChanged: (selection) {
                        notifier.updateUnitSystem(selection.first);
                      },
                      segments: const [
                        ButtonSegment<UnitSystem>(
                          value: UnitSystem.metric,
                          label: Text('Metric'),
                        ),
                        ButtonSegment<UnitSystem>(
                          value: UnitSystem.imperial,
                          label: Text('Imperial'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Theme',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      selected: {preferences.themeMode},
                      onSelectionChanged: (selection) {
                        notifier.updateThemeMode(selection.first);
                      },
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('System'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Light'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
