import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/services/notification_trigger.dart';

/// Development-only page for testing notifications
/// This page is only shown in debug mode
class NotificationTestPage extends ConsumerStatefulWidget {
  const NotificationTestPage({super.key});

  @override
  ConsumerState<NotificationTestPage> createState() =>
      _NotificationTestPageState();
}

class _NotificationTestPageState extends ConsumerState<NotificationTestPage> {
  bool _isLoading = false;
  String? _message;
  Color _messageColor = Colors.green;

  Future<void> _sendRecipeLikeNotification() async {
    _setLoading(true);
    try {
      final success = await NotificationTrigger.sendRecipeLikeNotification(
        recipeId: 'recipe_demo_123',
        recipeName: 'Spaghetti Carbonara',
        senderId: 'user_456',
        senderName: 'John Doe',
        recipientId: 'user_789',
        recipientFcmToken: 'demo_token',
      );

      _setMessage(
        success
            ? '✓ Recipe like notification sent & stored'
            : '✗ Failed to send recipe like notification',
        success ? Colors.green : Colors.red,
      );
    } catch (e) {
      _setMessage('Error: $e', Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _sendFollowNotification() async {
    _setLoading(true);
    try {
      final success = await NotificationTrigger.sendFollowNotification(
        followerId: 'user_456',
        followerName: 'Jane Smith',
        followedUserId: 'user_789',
        followedUserFcmToken: 'demo_token',
      );

      _setMessage(
        success
            ? '✓ Follow notification sent & stored'
            : '✗ Failed to send follow notification',
        success ? Colors.green : Colors.red,
      );
    } catch (e) {
      _setMessage('Error: $e', Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _sendMealReminderNotification() async {
    _setLoading(true);
    try {
      final success = await NotificationTrigger.sendMealReminderNotification(
        userId: 'user_789',
        mealName: 'Breakfast',
        userFcmToken: 'demo_token',
        plannerId: 'planner_demo_123',
      );

      _setMessage(
        success
            ? '✓ Meal reminder notification sent & stored'
            : '✗ Failed to send meal reminder notification',
        success ? Colors.green : Colors.red,
      );
    } catch (e) {
      _setMessage('Error: $e', Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _setMessage(String message, Color color) {
    setState(() {
      _message = message;
      _messageColor = color;
    });
  }

  void _clearMessage() {
    setState(() {
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test Lab'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Testing Notification System',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current User ID: ${currentUserId ?? "Not authenticated"}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'These buttons will:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1. Create a notification in Firestore'),
                          Text('2. Log the action (FCM would be sent via Cloud Functions)'),
                          Text('3. Demonstrate notification structure'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test buttons
            _buildTestButton(
              title: 'Send Recipe Like Notification',
              description:
                  'Simulates: User John Doe liked your Spaghetti Carbonara recipe',
              onPressed: _sendRecipeLikeNotification,
              icon: Icons.favorite,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              title: 'Send Follow Notification',
              description: 'Simulates: Jane Smith started following you',
              onPressed: _sendFollowNotification,
              icon: Icons.person_add,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              title: 'Send Meal Reminder Notification',
              description: 'Simulates: Time to have your Breakfast',
              onPressed: _sendMealReminderNotification,
              icon: Icons.notifications,
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            // Message display
            if (_message != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _messageColor.withValues(alpha: 0.1),
                  border: Border.all(color: _messageColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _messageColor == Colors.green
                          ? Icons.check_circle
                          : Icons.error,
                      color: _messageColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _messageColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearMessage,
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Info section
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Use',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Tap any button to send a test notification\n'
                      '2. Check Firestore Console → Collections → notifications\n'
                      '3. You should see a new notification document\n'
                      '4. In production, Cloud Functions would send FCM push\n'
                      '5. Users would receive push on their devices',
                      style: TextStyle(fontSize: 12, height: 1.6),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Notification Structure:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '{  "type": "recipe_like",\n'
                        '   "title": "Recipe Liked",\n'
                        '   "body": "User liked your recipe",\n'
                        '   "senderId": "user123",\n'
                        '   "recipientId": "user456",\n'
                        '   "entityId": "recipeId789"\n'
                        '}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String title,
    required String description,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(12),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
