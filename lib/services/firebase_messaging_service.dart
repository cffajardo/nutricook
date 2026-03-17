import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationCallback = Future<void> Function(RemoteMessage message);

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;
  NotificationCallback? _foregroundNotificationCallback;
  Function(String)? _notificationTapCallback;
  bool _isInitialized = false;

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  bool get isInitialized => _isInitialized;

  String? get fcmToken => _fcmToken;

  Future<bool> requestNotificationPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> initialize({
    required NotificationCallback onForegroundMessage,
    required Function(String notificationId) onNotificationTap,
  }) async {
    if (_isInitialized) {
      debugPrint('FirebaseMessagingService already initialized');
      return;
    }

    try {
      debugPrint('Initializing FirebaseMessagingService...');

      _foregroundNotificationCallback = onForegroundMessage;
      _notificationTapCallback = onNotificationTap;

      await requestNotificationPermission();

      await _initializeLocalNotifications();

      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification tapped: ${message.messageId}');
        _handleNotificationTap(message);
      });

      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iOSInit =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iOSInit,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            _notificationTapCallback?.call(response.payload!);
          }
        },
      );

      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'default_notification_channel',
          'Default Notifications',
          description: 'Channel for default notifications',
          importance: Importance.max,
          enableVibration: true,
          enableLights: true,
          playSound: true,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }

      debugPrint('Local notifications initialized');
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      debugPrint('Handling foreground message: ${message.messageId}');
      
      await _showLocalNotification(message);

      if (_foregroundNotificationCallback != null) {
        await _foregroundNotificationCallback!(message);
      }
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    try {
      debugPrint('Handling background message: ${message.messageId}');
    } catch (e) {
      debugPrint('Error handling background message: $e');
    }
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    try {
      final payloadData = message.data;
      final notificationId = message.messageId ?? 'unknown';
      
      debugPrint('Notification tap payload: $payloadData');
      
      if (_notificationTapCallback != null) {
        _notificationTapCallback!(notificationId);
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      final title = notification.title ?? 'NutriCook';
      final body = notification.body ?? '';
      final payload = message.messageId ?? '';

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'default_notification_channel',
        'Default Notifications',
        channelDescription: 'Channel for default notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      const DarwinNotificationDetails iOSDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        payload.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      debugPrint('Local notification shown: $title');
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  Future<void> saveFCMTokenToFirestore(String userId) async {
    try {
      if (_fcmToken == null) {
        debugPrint('No FCM token available to save');
        return;
      }

      await _firestore.collection('users').doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      //
    }
  }

  Future<String?> refreshFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM token refreshed: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('Error refreshing FCM token: $e');
      return null;
    }
  }

  Future<void> deleteFCMToken(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      _fcmToken = null;
      debugPrint('FCM token deleted for user: $userId');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  Future<RemoteMessage?> getInitialMessage() async {
    try {
      return await _firebaseMessaging.getInitialMessage();
    } catch (e) {
      debugPrint('Error getting initial message: $e');
      return null;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      if (enabled) {
        await _firebaseMessaging.setAutoInitEnabled(true);
      } else {
        await _firebaseMessaging.setAutoInitEnabled(false);
      }
    } catch (e) {
      //
    }
  }
}
