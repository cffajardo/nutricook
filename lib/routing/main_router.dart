import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/verify_email_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../features/planner/screens/planner_main.dart'; 

final routerProvider = Provider<GoRouter>((ref) {
  final userAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';
      final isVerifyEmailRoute = path == '/verify-email';
      final isSplashRoute = path == '/splash';

      if (isSplashRoute) return null;

      return userAsync.when(
        loading: () => null,
        error: (_, __) => '/login',
        data: (user) {
          if (user == null) {
            return isAuthRoute ? null : '/login';
          }

          final needsVerification =
              user.email != null &&
              user.email!.isNotEmpty &&
              !user.emailVerified;

          if (needsVerification) {
            return isVerifyEmailRoute ? null : '/verify-email';
          }

          if (isAuthRoute || isVerifyEmailRoute) {
            return '/';
          }

          // This allows navigation to '/' or '/planner' or any other protected route
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // --- NEW PLANNER ROUTE ADDED HERE ---
      GoRoute(
        path: '/planner',
        name: 'planner',
        builder: (context, state) => const PlannerScreen(),
      ),
      // ------------------------------------
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
    ],
  );
});