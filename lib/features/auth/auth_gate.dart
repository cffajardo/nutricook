import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserWithVerificationProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginScreen(),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        // Require verification only for email/password users (they have email)
        if (user.email != null &&
            user.email!.isNotEmpty &&
            !user.emailVerified) {
          return const VerifyEmailScreen();
        }
        return child;
      },
    );
  }
}
