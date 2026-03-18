import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiOverlayStyle, SystemUiMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/profile/provider/user_preferences_provider.dart';
import 'package:nutricook/services/firebase_messaging_service.dart';
import 'package:nutricook/features/notifications/notification_handler.dart';
import 'package:nutricook/models/notification_payload.dart';
import 'firebase_options.dart';
import 'routing/main_router.dart';
import 'package:nutricook/services/archive_service.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/admin/providers/create_ingredient_provider.dart';
import 'package:nutricook/features/library/ingredients/provider/ingredient_provider.dart';
import 'package:nutricook/services/generative_ai_service.dart';
import 'package:nutricook/services/ingredient_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initializeFirebaseMessaging();
  
  runApp(const ProviderScope(child: NutriCookApp()));
}

Future<void> _initializeFirebaseMessaging() async {
  try {
    final messagingService = FirebaseMessagingService();
    final initialMessage = await messagingService.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Initial message received: ${initialMessage.messageId}');
    }
    
    await messagingService.initialize(
      onForegroundMessage: (RemoteMessage message) async {
        debugPrint('Foreground message: ${message.messageId}');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
      },
      onNotificationTap: (String notificationId) {
        // Navigation done elsewhere
      },
    );
    
    debugPrint('Firebase Messaging initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase Messaging: $e');
  }
}


class NutriCookApp extends ConsumerWidget {
  const NutriCookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appThemeModeProvider);

    // Trigger archive cleanup on login (Past archive date)
    ref.listen(currentUserIdProvider, (previous, next) {
      if (next != null && next.isNotEmpty && previous != next) {
        ref.read(archiveServiceProvider).runCleanup();
        ref.read(ingredientServiceProvider).enrichMissingProperties(
              ref.read(generativeAiServiceProvider),
            );
      }
    });
    _setupNotificationTapListener(context);

    return MaterialApp.router(
      title: 'NutriCook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child,
        );
      },
    );
  }

  void _setupNotificationTapListener(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened from app: ${message.messageId}');
      
      try {
        final payload = NotificationPayload.fromFCMData(
          notificationId: message.messageId ?? 'unknown',
          data: message.data,
          title: message.notification?.title,
          body: message.notification?.body,
        );
        
        debugPrint('Parsed payload: $payload');
        
        // Handle notification tap navigation
        if (context.mounted) {
          NotificationHandler.handleNotificationTap(
            context: context,
            payload: payload,
          );
        }
      } catch (e) {
        debugPrint('Error handling notification tap: $e');
      }
    });
  }
}
