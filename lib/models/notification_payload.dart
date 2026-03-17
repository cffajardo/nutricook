import 'package:nutricook/core/enums/notification_type.dart';


class NotificationPayload {
  final String notificationId;
  final NotificationType type;
  final String? entityId;
  final String? senderId;
  final String title;
  final String? body;
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

  factory NotificationPayload.fromFCMData({
    required String notificationId,
    required Map<String, dynamic> data,
    String? title,
    String? body,
  }) {
    final typeString = data['type'] as String?;
    final type = NotificationType.fromString(typeString) ??
        NotificationType.recipeLike; 

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

  static const Set<String> _systemKeys = {
    'type',
    'entityId',
    'senderId',
  };

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
