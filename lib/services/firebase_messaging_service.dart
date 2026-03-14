import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationCallback = Future<void> Function(RemoteMessage message);

/// Firebase Cloud Messaging Service
/// Handles FCM token management, permissions, and message routing
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

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get the FCM token
  String? get fcmToken => _fcmToken;

  /// Request notification permissions (iOS & Android 13+)
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

      debugPrint(
          'Notification permission status: ${settings.authorizationStatus}');
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Initialize Firebase Messaging and Local Notifications
  /// [onForegroundMessage] - Called when notification arrives in foreground
  /// [onNotificationTap] - Called when notification is tapped (passes notification ID)
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

      // Store callbacks
      _foregroundNotificationCallback = onForegroundMessage;
      _notificationTapCallback = onNotificationTap;

      // Request permission
      await requestNotificationPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get and cache FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        // Note: Token refresh is handled by re-initialization in main.dart
      });

      // Set up message handlers
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification tapped: ${message.messageId}');
        _handleNotificationTap(message);
      });

      // Set up background message handler (static)
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      _isInitialized = true;
      debugPrint('FirebaseMessagingService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FirebaseMessagingService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Initialize local notifications for Android and iOS
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
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
          debugPrint('Local notification tapped: ${response.payload}');
          if (response.payload != null) {
            _notificationTapCallback?.call(response.payload!);
          }
        },
      );

      // Create default notification channel for Android 8+
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

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      debugPrint('Handling foreground message: ${message.messageId}');
      
      // Show local notification
      await _showLocalNotification(message);

      // Call the foreground notification callback
      if (_foregroundNotificationCallback != null) {
        await _foregroundNotificationCallback!(message);
      }
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  /// Handle background messages (static - cannot access instance)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    try {
      debugPrint('Handling background message: ${message.messageId}');
      // Background message handling is done by FCM
      // App will show notification from FCM system
    } catch (e) {
      debugPrint('Error handling background message: $e');
    }
  }

  /// Handle notification tap
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

  /// Show local notification (for foreground messages)
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

  /// Save FCM token to Firestore user document
  /// Called after successful authentication
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

      debugPrint('FCM token saved to Firestore for user: $userId');
    } catch (e) {
      debugPrint('Error saving FCM token to Firestore: $e');
      // Don't rethrow - failure to save token shouldn't block login
    }
  }

  /// Refresh FCM token (call this periodically or on token refresh)
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

  /// Delete FCM token (call on logout)
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

  /// Get initial message (for when app is opened from notification while closed)
  Future<RemoteMessage?> getInitialMessage() async {
    try {
      return await _firebaseMessaging.getInitialMessage();
    } catch (e) {
      debugPrint('Error getting initial message: $e');
      return null;
    }
  }

  /// Enable/disable notifications at app level
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      if (enabled) {
        await _firebaseMessaging.setAutoInitEnabled(true);
      } else {
        await _firebaseMessaging.setAutoInitEnabled(false);
      }
      debugPrint('Notifications enabled: $enabled');
    } catch (e) {
      debugPrint('Error setting notifications enabled: $e');
    }
  }
}
