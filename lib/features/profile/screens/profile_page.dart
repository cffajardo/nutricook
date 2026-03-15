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
import 'package:nutricook/features/collection/screens/create_collection_modal.dart';
import 'package:nutricook/features/collection/screens/collection_detail_modal.dart';
import 'package:nutricook/features/collection/screens/collection_recipes_screen.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/services/collection_service.dart';

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
  void deactivate() {
    // Close any open modals when page loses focus (navigation away)
    _closeOpenModals();
    super.deactivate();
  }

  @override
  void dispose() {
    // Close any open modals before disposing
    _closeOpenModals();
    tabController.dispose();
    super.dispose();
  }

  void _closeOpenModals() {
    // Close all open modals (Collection Detail, Edit Collection, etc.)
    // by repeatedly popping until modals are closed
    try {
      final navigator = Navigator.of(context, rootNavigator: true);
      // Keep popping modals - modal bottom sheets are MaterialPageRoute with ModalRoute
      // We'll pop them off the stack
      int popCount = 0;
      while (navigator.canPop() && popCount < 10) {
        // Safety limit to avoid infinite loops
        navigator.maybePop();
        popCount++;
      }
    } catch (e) {
      // Silently ignore if navigator is not available
    }
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
      queryParameters: {'userId': userId, 'tab': '$initialTab'},
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
          final followersCount = followersUsersAsync.asData?.value.length ?? 0;
          final followingCount = followingUsersAsync.asData?.value.length ?? 0;

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
                  backgroundImage:
                      profileImageUrl != null && profileImageUrl.isNotEmpty
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
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

        return Container(
          color: const Color(0xFFFFF9FA),
          child: GridView.builder(
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
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        debugPrint('Recipe Grid Error: $error');
        debugPrint('Stack trace: $stackTrace');
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load recipes',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollectionsTab(
    AsyncValue<List<Collection>> userCollectionsAsync,
  ) {
    final isOwnProfile = widget.userId == null;
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
                if (isOwnProfile) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showCreateCollectionModal(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Collection'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.rosePink,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isOwnProfile)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showCreateCollectionModal(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New Collection'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.rosePink,
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _showCollectionDetail(collection, isOwnProfile),
                      child: _buildCollectionCard(
                        collection,
                        isOwnProfile: isOwnProfile,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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

  Widget _buildCollectionCard(
    Collection collection, {
    required bool isOwnProfile,
  }) {
    final isFavoritesCollection = collection.isDefault;

    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: isFavoritesCollection
            ? AppColors.rosePink.withValues(alpha: 0.15)
            : AppColors.cardRose.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFavoritesCollection
              ? AppColors.rosePink.withValues(alpha: 0.5)
              : AppColors.rosePink.withValues(alpha: 0.2),
          width: isFavoritesCollection ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              collection.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (isFavoritesCollection) const SizedBox(width: 4),
                          if (isFavoritesCollection)
                            const Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: AppColors.rosePink,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isFavoritesCollection
                        ? AppColors.rosePink.withValues(alpha: 0.2)
                        : AppColors.rosePink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${collection.recipeCount} recipes',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.rosePink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isOwnProfile && !isFavoritesCollection)
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    _showEditCollectionModal(collection);
                  } else if (action == 'delete') {
                    _showDeleteCollectionDialog(collection);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.rosePink.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 16,
                    color: AppColors.rosePink,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateCollectionModal() async {
    if (!mounted) return;
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, 
      useRootNavigator: true,  
      backgroundColor: Colors.transparent, 
      useSafeArea: true,      
      builder: (ctx) => CreateCollectionModal(
        onCollectionCreated: () {
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _showCollectionDetail(Collection collection, bool isOwnProfile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      useSafeArea: true, 
      builder: (ctx) => CollectionDetailModal(
        collection: collection,
        isOwner: isOwnProfile,
        onEdit: () => _showEditCollectionModal(collection),
        onDelete: () => _showDeleteCollectionDialog(collection),
        onViewRecipes: () {
          Navigator.of(ctx).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollectionRecipesScreen(collection: collection),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditCollectionModal(Collection collection) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: CreateCollectionModal(
          isEditMode: true,
          collectionId: collection.id,
          initialName: collection.name,
          initialDescription: collection.description,
          initialIsPublic: collection.isPublic,
          onCollectionCreated: () {
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteCollectionDialog(Collection collection) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Collection?'),
        content: Text(
          'Are you sure you want to delete "${collection.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await CollectionService().deleteCollection(collection.id);
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Collection deleted.')),
                );
              } catch (e) {
                if (!mounted) return;
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
