import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/routing/app_routes.dart';

class FollowersFollowingPage extends ConsumerStatefulWidget {
  const FollowersFollowingPage({
    super.key,
    required this.userId,
    this.initialTab = 0,
  });

  final String userId;
  final int initialTab;

  @override
  ConsumerState<FollowersFollowingPage> createState() =>
      _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends ConsumerState<FollowersFollowingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isConnectionActionLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _unfollow({
    required String targetUserId,
    required String currentUserId,
  }) async {
    if (_isConnectionActionLoading || currentUserId == targetUserId) return;

    setState(() => _isConnectionActionLoading = true);
    try {
      final userService = ref.read(userServiceProvider);
      await userService.unfollowUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      ref.invalidate(followingUsersByUserIdQueryProvider(currentUserId));
      ref.invalidate(followersUsersByUserIdQueryProvider(currentUserId));
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
        setState(() => _isConnectionActionLoading = false);
      }
    }
  }

  Future<void> _removeFollower({
    required String followerUserId,
    required String currentUserId,
  }) async {
    if (_isConnectionActionLoading || currentUserId == followerUserId) return;

    setState(() => _isConnectionActionLoading = true);
    try {
      final userService = ref.read(userServiceProvider);
      await userService.unfollowUser(
        currentUserId: followerUserId,
        targetUserId: currentUserId,
      );
      ref.invalidate(followingUsersByUserIdQueryProvider(currentUserId));
      ref.invalidate(followersUsersByUserIdQueryProvider(currentUserId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed to remove follower: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isConnectionActionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final effectiveUserId =
        widget.userId.trim().isNotEmpty ? widget.userId : (currentUserId ?? '');
    final canManageConnections =
        currentUserId != null && currentUserId == effectiveUserId;

    if (effectiveUserId.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF9FA),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text(
            'Connections',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: const Center(
          child: Text(
            'Could not load connections. Missing user id.',
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final profileAsync = canManageConnections
        ? ref.watch(userDataProvider)
        : ref.watch(userDataByIdProvider(effectiveUserId));
    final followersAsync = ref.watch(
      followersUsersByUserIdQueryProvider(effectiveUserId),
    );
    final followingAsync = ref.watch(
      followingUsersByUserIdQueryProvider(effectiveUserId),
    );

    final profileData = profileAsync.asData?.value;
    final username = ((profileData is Map<String, dynamic>
                ? profileData['username']
                : null) ??
            'Connections')
        .toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9FA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          '@$username',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.rosePink,
          indicatorWeight: 3,
          labelColor: AppColors.rosePink,
          unselectedLabelColor: Colors.black45,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
          tabs: [
            Tab(text: 'Followers ${followersAsync.asData?.value.length ?? 0}'),
            Tab(text: 'Following ${followingAsync.asData?.value.length ?? 0}'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersList(
                  usersAsync: followersAsync,
                  currentUserId: currentUserId,
                  canManageConnections: canManageConnections,
                  tab: _ConnectionsTab.followers,
                ),
                _buildUsersList(
                  usersAsync: followingAsync,
                  currentUserId: currentUserId,
                  canManageConnections: canManageConnections,
                  tab: _ConnectionsTab.following,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList({
    required AsyncValue<List<Map<String, dynamic>>> usersAsync,
    required String? currentUserId,
    required bool canManageConnections,
    required _ConnectionsTab tab,
  }) {
    final tabLabel = tab == _ConnectionsTab.followers ? 'Followers' : 'Following';

    return usersAsync.when(
      loading: () => _buildStateContainer(
        label: '$tabLabel • Loading...',
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _buildStateContainer(
        label: '$tabLabel • Error',
        child: Center(
          child: Text(
            'Failed to load users: $error',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ),
      data: (users) => _buildStateContainer(
        label: '$tabLabel • ${users.length} user(s)',
        child: users.isEmpty
            ? const Center(
                child: Text(
                  'No users found.',
                  style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w700),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < users.length; i++) ...[
                      _buildUserCardSafely(
                        userRaw: users[i],
                        index: i,
                        currentUserId: currentUserId,
                        canManageConnections: canManageConnections,
                        tab: tab,
                      ),
                      if (i != users.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStateContainer({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF9FA),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildUserCardSafely({
    required Object? userRaw,
    required int index,
    required String? currentUserId,
    required bool canManageConnections,
    required _ConnectionsTab tab,
  }) {
    try {
      if (userRaw is! Map) {
        return _buildBrokenRow(index, 'Row is not a map: ${userRaw.runtimeType}');
      }

      final user = <String, dynamic>{};
      userRaw.forEach((key, value) {
        user[key.toString()] = value;
      });

      final userId = (user['id'] ?? '').toString();
      final username = (user['username'] ?? 'Unknown').toString();
      final profileImageUrl = (user['mediaId'] ?? user['profilePictureUrl'])?.toString();
      final isSelf = currentUserId != null && userId == currentUserId;

      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: userId.isEmpty
            ? null
            : () {
                if (isSelf) {
                  context.goNamed(AppRoutes.profileName);
                  return;
                }
                context.pushNamed(
                  AppRoutes.profileUserName,
                  pathParameters: {'userId': userId},
                );
              },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.rosePink.withValues(alpha: 0.16),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.cardRose,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: profileImageUrl != null &&
                        profileImageUrl.isNotEmpty &&
                        (profileImageUrl.startsWith('http://') ||
                            profileImageUrl.startsWith('https://'))
                    ? Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: AppColors.rosePink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppColors.rosePink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (!isSelf && currentUserId != null && canManageConnections)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 0,
                    maxWidth: 110,
                    minHeight: 34,
                    maxHeight: 34,
                  ),
                  child: ElevatedButton(
                    onPressed: _isConnectionActionLoading
                        ? null
                        : () {
                            if (tab == _ConnectionsTab.following) {
                              _unfollow(
                                targetUserId: userId,
                                currentUserId: currentUserId,
                              );
                            } else {
                              _removeFollower(
                                followerUserId: userId,
                                currentUserId: currentUserId,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size(0, 34),
                      maximumSize: const Size(110, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: tab == _ConnectionsTab.following
                          ? Colors.white
                          : Colors.redAccent,
                      side: BorderSide(
                        color: tab == _ConnectionsTab.following
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.redAccent,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      tab == _ConnectionsTab.following ? 'Unfollow' : 'Remove',
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: tab == _ConnectionsTab.following
                            ? Colors.black87
                            : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      return _buildBrokenRow(index, e.toString());
    }
  }

  Widget _buildBrokenRow(int index, String reason) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Could not render user row #$index: $reason',
        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
      ),
    );
  }
}

enum _ConnectionsTab { followers, following }
