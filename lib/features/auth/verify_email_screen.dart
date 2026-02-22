import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isSending = false;
  bool _isChecking = false;
  String? _message;

  Future<void> _resendVerification() async {
    setState(() {
      _isSending = true;
      _message = null;
    });

    try {
      await ref.read(authProvider).sendEmailVerification();
      if (mounted) {
        setState(() {
          _isSending = false;
          _message = 'Verification email sent! Check your inbox.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
          _message = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });

    try {
      await ref.read(authProvider).reloadCurrentUser();
      final user = ref.read(authProvider).currentUser;
      if (mounted) {
        setState(() => _isChecking = false);
        if (user?.emailVerified == true) {
          ref.read(verificationRefreshProvider.notifier).increment();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified!')),
          );
        } else {
          setState(() => _message = 'Not verified yet. Click the link in your email.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _message = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _signOut() async {
    await ref.read(authProvider).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authProvider).currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Verify your email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We sent a verification link to',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Click the link in that email to verify you own this address. '
                'Then come back here and tap the button below.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _message!.startsWith('Verification')
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.startsWith('Verification')
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isChecking ? null : _checkVerificationStatus,
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isChecking ? 'Checking...' : "I've verified my email"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSending ? null : _resendVerification,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Resend verification email'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _signOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
