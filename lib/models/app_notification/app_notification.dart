import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.type,
    this.entityId,
    this.senderId,
    this.isRead = false,
  });

  final String id;
  final String recipientId;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? type;
  final String? entityId;
  final String? senderId;
  final bool isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      recipientId: (json['recipientId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      createdAt: _readDateTime(json['createdAt']),
      type: json['type']?.toString(),
      entityId: json['entityId']?.toString(),
      senderId: json['senderId']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type,
      'entityId': entityId,
      'senderId': senderId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _readDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.now();
  }
}
