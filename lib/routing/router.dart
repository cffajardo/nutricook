import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../screens/home_screen.dart';

/// Holds auth state for router redirects. Updated when auth changes.
class RouterAuthNotifier extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;

  void update(User? user, {bool isLoading = false}) {
    final userChanged = _user != user;
    final loadingChanged = _isLoading != isLoading;
    _user = user;
    _isLoading = isLoading;
    if (userChanged || loadingChanged) {
      notifyListeners();
    }
  }
}

final routerAuthNotifierProvider =
    Provider<RouterAuthNotifier>((ref) => RouterAuthNotifier());

/// Syncs auth state from Riverpod to the router's refresh notifier.
class AuthStateSync extends ConsumerStatefulWidget {
  const AuthStateSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthStateSync> createState() => _AuthStateSyncState();
}

class _AuthStateSyncState extends ConsumerState<AuthStateSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    final authNotifier = ref.read(routerAuthNotifierProvider);
    final userAsync = ref.read(currentUserWithVerificationProvider);

    userAsync.when(
      loading: () => authNotifier.update(null, isLoading: true),
      error: (_, __) => authNotifier.update(null, isLoading: false),
      data: (user) => authNotifier.update(user, isLoading: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserWithVerificationProvider, (_, __) => _sync());
    return widget.child;
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Main app router with auth-aware redirects.
GoRouter createRouter(RouterAuthNotifier authNotifier) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final user = authNotifier.user;
      final isLoading = authNotifier.isLoading;
      final path = state.uri.path;

      final isAuthRoute = path == '/login' || path == '/register';
      final isVerifyEmailRoute = path == '/verify-email';

      // During initial auth load, show login (avoids flash of wrong screen)
      if (isLoading) return isAuthRoute ? null : '/login';

      // Not logged in -> login (unless already on auth route)
      if (user == null) {
        return isAuthRoute ? null : '/login';
      }

      // Logged in, email not verified -> verify-email (unless already there)
      final needsVerification = user.email != null &&
          user.email!.isNotEmpty &&
          !user.emailVerified;
      if (needsVerification) {
        return isVerifyEmailRoute ? null : '/verify-email';
      }

      // Logged in and verified -> home (redirect away from auth routes)
      if (isAuthRoute || isVerifyEmailRoute) {
        return '/';
      }

      return null;
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
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(routerAuthNotifierProvider);
  return createRouter(authNotifier);
});
