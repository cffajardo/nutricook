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
                    await ref
                        .read(notificationServiceProvider)
                        .markNotificationAsRead(item.id);
                  }

                  // Route based on notification type
                  if (context.mounted && item.type != null) {
                    final notificationType = NotificationType.fromString(item.type);
                    if (notificationType != null) {
                      switch (notificationType) {
                        case NotificationType.recipeLike:
                          if (item.entityId != null) {
                            try {
                              debugPrint(
                                  'Fetching recipe: ${item.entityId}');
                              // Fetch the recipe first
                              final recipeService = RecipeService();
                              final recipe = await recipeService
                                  .getRecipeById(item.entityId!)
                                  .first;
                              
                              if (recipe != null && context.mounted) {
                                debugPrint(
                                    'Navigating to recipe: ${recipe.id}');
                                context.pushNamed(
                                  AppRoutes.recipeDetailsName,
                                  extra: recipe,
                                );
                              }
                            } catch (e) {
                              debugPrint('Error fetching recipe: $e');
                            }
                          }
                          break;
                        case NotificationType.follow:
                          if (item.senderId != null) {
                            debugPrint(
                                'Navigating to profile: ${item.senderId}');
                            context.pushNamed(
                              AppRoutes.profileUserName,
                              pathParameters: {'userId': item.senderId!},
                            );
                          }
                          break;
                        case NotificationType.mealReminder:
                          debugPrint('Navigating to meal planner');
                          context.pushNamed(AppRoutes.plannerName);
                          break;
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
