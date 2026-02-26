import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final userAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';
      final isVerifyEmailRoute = path == '/verify-email';

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

          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
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