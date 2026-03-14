import 'package:nutricook/core/enums/notification_type.dart';

/// Type-safe notification payload for routing and handling
class NotificationPayload {
  /// Unique notification ID
  final String notificationId;

  /// Type of notification
  final NotificationType type;

  /// ID of the entity related to the notification (recipeId, userId, plannerId, etc.)
  final String? entityId;

  /// ID of the user who triggered the notification (liker, follower, etc.)
  final String? senderId;

  /// Notification title
  final String title;

  /// Notification body/message
  final String? body;

  /// Additional metadata
  final Map<String, String> metadata;

  const NotificationPayload({
    required this.notificationId,
    required this.type,
    this.entityId,
    this.senderId,
    required this.title,
    this.body,
    this.metadata = const {},
  });

  /// Create NotificationPayload from FCM data payload
  factory NotificationPayload.fromFCMData({
    required String notificationId,
    required Map<String, dynamic> data,
    String? title,
    String? body,
  }) {
    final typeString = data['type'] as String?;
    final type = NotificationType.fromString(typeString) ??
        NotificationType.recipeLike; // Default to recipeLike

    return NotificationPayload(
      notificationId: notificationId,
      type: type,
      entityId: data['entityId'] as String?,
      senderId: data['senderId'] as String?,
      title: title ?? 'NutriCook',
      body: body,
      metadata: Map<String, String>.from(
        Map.fromEntries(
          data.entries
              .where((e) => e.value is String && !_systemKeys.contains(e.key))
              .map((e) => MapEntry(e.key, e.value as String)),
        ),
      ),
    );
  }

  /// System keys that shouldn't be included in metadata
  static const Set<String> _systemKeys = {
    'type',
    'entityId',
    'senderId',
  };

  /// Convert to map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      'entityId': entityId,
      'senderId': senderId,
      'title': title,
      'body': body,
      'metadata': metadata,
    };
  }

  @override
  String toString() =>
      'NotificationPayload(id: $notificationId, type: ${type.value}, entity: $entityId, sender: $senderId)';
}
