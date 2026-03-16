import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/core/enums/notification_type.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/notifications/provider/notification_provider.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/services/recipe_service.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        actions: [
          if (userId != null)
            TextButton(
              onPressed: () {
                ref.read(notificationServiceProvider).markAllAsRead(userId);
              },
              child: const Text('Mark all read'),
            ),
          if (userId != null)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Notifications?'),
                    content: const Text(
                      'This will permanently delete all your notifications.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(notificationServiceProvider)
                              .clearAllNotifications(userId);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear all'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load notifications: $error',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = notifications[index];
              final createdAt = item.createdAt;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  // Mark notification as read
                  if (!item.isRead) {
                    try {
                      await ref
                          .read(notificationServiceProvider)
                          .markNotificationAsRead(item.id);
                      // The Firestore stream will automatically update the UI
                    } catch (e) {
                      debugPrint('Error marking notification as read: $e');
                    }
                  }

                  // For recipe deleted notifications, only mark as read (no navigation)
                  if (item.type != null) {
                    final notificationType = NotificationType.fromString(item.type);
                    if (notificationType == NotificationType.recipeDeleted) {
                      debugPrint('Recipe deleted notification - marked as read only');
                      return;
                    }
                  }

                  // Route based on notification type (for other notification types)
                  if (!context.mounted) return;
                  
                  if (item.type != null) {
                    final notificationType = NotificationType.fromString(item.type);
                    if (notificationType != null) {
                      try {
                        switch (notificationType) {
                          case NotificationType.recipeLike:
                            if (item.entityId != null) {
                              debugPrint('Fetching recipe: ${item.entityId}');
                              final recipeService = RecipeService();
                              final recipe = await recipeService
                                  .getRecipeById(item.entityId!)
                                  .first;
                              
                              if (recipe != null && context.mounted) {
                                debugPrint('Navigating to recipe: ${recipe.id}');
                                await context.pushNamed(
                                  AppRoutes.recipeDetailsName,
                                  extra: recipe,
                                );
                              } else if (!context.mounted) {
                                return;
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Recipe not found')),
                                  );
                                }
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Recipe ID not found in notification')),
                                );
                              }
                            }
                            break;
                          case NotificationType.follow:
                            if (item.senderId != null) {
                              debugPrint('Navigating to profile: ${item.senderId}');
                              if (context.mounted) {
                                await context.pushNamed(
                                  AppRoutes.profileUserName,
                                  pathParameters: {'userId': item.senderId!},
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User ID not found in notification')),
                                );
                              }
                            }
                            break;
                          case NotificationType.mealReminder:
                            debugPrint('Navigating to meal planner');
                            if (context.mounted) {
                              await context.pushNamed(AppRoutes.plannerName);
                            }
                            break;
                          case NotificationType.recipeDeleted:
                            // This case is handled above with early return
                            break;
                        }
                      } catch (e) {
                        debugPrint('Error navigating from notification: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Navigation error: $e')),
                          );
                        }
                      }
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.isRead ? Colors.white : AppColors.cardRose,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.isRead
                          ? Colors.black12
                          : AppColors.rosePink.withValues(alpha: 0.35),
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.isRead
                            ? Icons.notifications_none_rounded
                            : Icons.notifications_active_rounded,
                        color: AppColors.rosePink,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.body,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${createdAt.month}/${createdAt.day}/${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black38,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
