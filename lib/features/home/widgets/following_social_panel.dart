import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/routing/app_routes.dart';

class FollowingSocialPanel extends ConsumerStatefulWidget {
  const FollowingSocialPanel({super.key});

  @override
  ConsumerState<FollowingSocialPanel> createState() =>
      _FollowingSocialPanelState();
}

class _FollowingSocialPanelState extends ConsumerState<FollowingSocialPanel> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _loadingKeys = <String>{};
  String _query = '';

  void _showRootSnackBar(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(
      Navigator.of(context, rootNavigator: true).context,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runAction({
    required String key,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    if (_loadingKeys.contains(key)) return;

    setState(() => _loadingKeys.add(key));
    try {
      await action();
      _showRootSnackBar(successMessage);
    } catch (e) {
      _showRootSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loadingKeys.remove(key));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserIdProvider);
    final userService = ref.watch(userServiceProvider);
    final discoverAsync = ref.watch(discoverUsersProvider(_query));
    final followingIds =
        ref.watch(userFollowingIdsProvider).asData?.value ?? const <String>[];
    final blockedIds =
        ref.watch(blockedUserIdsProvider).asData?.value ?? const <String>[];
    final blockedUsers =
        ref.watch(blockedUsersProvider).asData?.value ??
        const <Map<String, dynamic>>[];

    if (uid == null) {
      return const Center(
        child: Text(
          'Sign in to manage your social feed.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search users',
              isDense: true,
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Following ${followingIds.length} • Blocked ${blockedIds.length}',
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: discoverAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(color: Colors.black45),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: users.length > 4 ? 4 : users.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final targetId = (user['id'] ?? '').toString();
                    final username = (user['username'] ?? 'Unknown user')
                        .toString();
                    final isBlocked = blockedIds.contains(targetId);
                    final isFollowing = followingIds.contains(targetId);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.rosePink.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.rosePink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: targetId.isEmpty
                                  ? null
                                  : () {
                                      if (targetId == uid) {
                                        context.goNamed(AppRoutes.profileName);
                                        return;
                                      }

                                      context.pushNamed(
                                        AppRoutes.profileUserName,
                                        pathParameters: {'userId': targetId},
                                      );
                                    },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 2,
                                ),
                                child: Text(
                                  '@$username',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!isBlocked)
                            TextButton(
                              onPressed:
                                  _loadingKeys.contains('follow-$targetId')
                                  ? null
                                  : () => _runAction(
                                      key: 'follow-$targetId',
                                      action: () {
                                        if (isFollowing) {
                                          return userService.unfollowUser(
                                            currentUserId: uid,
                                            targetUserId: targetId,
                                          );
                                        }
                                        return userService.followUser(
                                          currentUserId: uid,
                                          targetUserId: targetId,
                                        );
                                      },
                                      successMessage: isFollowing
                                          ? 'Unfollowed @$username'
                                          : 'Following @$username',
                                    ),
                              child: Text(isFollowing ? 'Following' : 'Follow'),
                            ),
                          TextButton(
                            onPressed: _loadingKeys.contains('block-$targetId')
                                ? null
                                : () => _runAction(
                                    key: 'block-$targetId',
                                    action: () {
                                      if (isBlocked) {
                                        return userService.unblockUser(
                                          currentUserId: uid,
                                          targetUserId: targetId,
                                        );
                                      }
                                      return userService.blockUser(
                                        currentUserId: uid,
                                        targetUserId: targetId,
                                      );
                                    },
                                    successMessage: isBlocked
                                        ? 'Unblocked @$username'
                                        : 'Blocked @$username',
                                  ),
                            child: Text(isBlocked ? 'Unblock' : 'Block'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load users: $e',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ),
          if (blockedUsers.isNotEmpty)
            SizedBox(
              height: 26,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: blockedUsers.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final name = (blockedUsers[index]['username'] ?? 'user')
                      .toString();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Blocked @$name',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
