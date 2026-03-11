import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/features/collection/provider/collection_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/features/recipe/providers/recipe_provider.dart';
import 'package:nutricook/features/recipe/widgets/recipe_card.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/recipe/recipe.dart';

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

  void _openSettings() {
    context.push('${AppRoutes.profilePath}/${AppRoutes.settingsPath}');
  }

  void _openEditProfile() {
    context.push('${AppRoutes.profilePath}/${AppRoutes.editProfilePath}');
  }

  void _openConnections({required String userId, required int initialTab}) {
    context.pushNamed(
      AppRoutes.profileConnectionsName,
      queryParameters: {
        'userId': userId,
        'tab': '$initialTab',
      },
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
    final colorScheme = Theme.of(context).colorScheme;
    final authUser = ref.watch(authStateProvider).asData?.value;
    final currentUserId = ref.watch(currentUserIdProvider);
    final viewedUserId = widget.userId ?? currentUserId;

    if (viewedUserId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Sign in to view profile.',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
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
    final followersUsersAsync = ref.watch(
      followersUsersByUserIdQueryProvider(viewedUserId),
    );
    final followingUsersAsync = ref.watch(
      followingUsersByUserIdQueryProvider(viewedUserId),
    );

    final followingIds =
        ref.watch(userFollowingIdsProvider).asData?.value ?? const <String>[];
    final isFollowing = followingIds.contains(viewedUserId);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9FA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (isOwnProfile)
            IconButton(
              onPressed: _openSettings,
              icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
            ),
        ],
      ),
      body: userDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load profile: $error',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
        data: (userData) {
          final resolvedUserData =
              userData ??
              (isOwnProfile && authUser != null
                  ? <String, dynamic>{
                      'username': authUser.displayName ?? 'Chef',
                      'email': authUser.email ?? '',
                      'followers': const <String>[],
                      'following': const <String>[],
                    }
                  : null);

          if (resolvedUserData == null) {
            return Center(
              child: Text(
                'Profile unavailable. Please sign in again.',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            );
          }

          final recipeCount = userRecipesAsync.asData?.value.length ?? 0;
          final collectionCount =
              userCollectionsAsync.asData?.value.length ?? 0;
            final followersCount =
              followersUsersAsync.asData?.value.length ?? 0;
            final followingCount =
              followingUsersAsync.asData?.value.length ?? 0;

          return Column(
            children: [
              _buildProfileHeader(
                userData: resolvedUserData,
                viewedUserId: viewedUserId,
                recipeCount: recipeCount,
                collectionCount: collectionCount,
                followersCount: followersCount,
                followingCount: followingCount,
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
                unselectedLabelColor: colorScheme.onSurface.withValues(
                  alpha: 0.45,
                ),
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
    required String viewedUserId,
    required int recipeCount,
    required int collectionCount,
    required int followersCount,
    required int followingCount,
    required bool isOwnProfile,
    required bool isFollowing,
    required bool canFollow,
    required VoidCallback onToggleFollow,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final username = (userData['username'] ?? 'Chef').toString();
    final email = (userData['email'] ?? '').toString();
    final profileImageUrl =
        (userData['mediaId'] ?? userData['profilePictureUrl'])?.toString();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.rosePink, width: 1.8),
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.cardRose,
                  backgroundImage: profileImageUrl != null &&
                          profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl == null || profileImageUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.rosePink,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '$collectionCount collections',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.rosePink.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('$recipeCount', 'Recipes'),
                _buildStatItem(
                  '$followersCount',
                  'Followers',
                  onTap: () =>
                      _openConnections(userId: viewedUserId, initialTab: 0),
                ),
                _buildStatItem(
                  '$followingCount',
                  'Following',
                  onTap: () =>
                      _openConnections(userId: viewedUserId, initialTab: 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isOwnProfile
                  ? _openEditProfile
                  : canFollow && !_isFollowActionLoading
                  ? onToggleFollow
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOwnProfile
                    ? colorScheme.surface
                    : isFollowing
                    ? colorScheme.surface
                    : AppColors.rosePink,
                elevation: 0,
                side: BorderSide(
                  color: isOwnProfile
                      ? colorScheme.onSurface.withValues(alpha: 0.18)
                      : isFollowing
                      ? colorScheme.onSurface.withValues(alpha: 0.18)
                      : AppColors.rosePink,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isOwnProfile
                    ? 'Edit Profile'
                    : _isFollowActionLoading
                    ? 'Working...'
                    : isFollowing
                    ? 'Following'
                    : 'Follow',
                style: TextStyle(
                  color: isOwnProfile || isFollowing
                      ? colorScheme.onSurface.withValues(alpha: 0.75)
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

  Widget _buildStatItem(String value, String label, {VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(AsyncValue<List<Recipe>> userRecipesAsync) {
    return userRecipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Text(
              'No recipes yet',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.65),
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
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
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
                Text(
                  'No collections yet',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
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
                color: Theme.of(context).colorScheme.surface,
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
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${collection.recipeCount} recipes',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
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
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

