import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../models/app_user/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


//Service Provider
final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase Auth State Stream Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authProvider);
  return authService.authStateChanges();
});

class VerificationRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final verificationRefreshProvider =
    NotifierProvider<VerificationRefreshNotifier, int>(
        VerificationRefreshNotifier.new);

/// User with fresh emailVerified status. Reloads when verificationRefreshProvider changes.
final currentUserWithVerificationProvider = FutureProvider<User?>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  ref.watch(verificationRefreshProvider);
  if (user == null) return null;
  await ref.read(authProvider).reloadCurrentUser();
  return ref.read(authProvider).currentUser;
});

// Current UID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value?.uid;
});

//Logged in status provider
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value != null;
});


//Stream provider for current user data from Firestore
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .snapshots()
    .map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc.data()!);
    });
});


//Sign In Provider
final signInWithIdentifierProvider = FutureProvider.autoDispose.family<void, Map<String, String>>((ref, credentials) async {
  final authService = ref.read(authProvider);
  await authService.signInWithIdentifier(
    identifier: credentials['identifier']!,
    password: credentials['password']!,
  );
});

//Register with Email Provider
final registerWithEmailProvider = FutureProvider.autoDispose.family<void, Map<String, String>>((ref, credentials) async {
  final authService = ref.read(authProvider);
  await authService.registerWithEmail(
    email: credentials['email']!,
    password: credentials['password']!,
    username: credentials['username']!,
  );
});

//Google Sign In Provider
final signInWithGoogleProvider = FutureProvider.autoDispose<void>((ref) async {
  final authService = ref.read(authProvider);
  await authService.signInWithGoogle();
});

//Sign Out Provider
final signOutProvider = FutureProvider.autoDispose<void>((ref) async {
  final authService = ref.read(authProvider);
  await authService.signOut();
});

//Send Password Reset Email Provider
final sendPasswordResetEmailProvider = FutureProvider.autoDispose.family<void, String>((ref, email) async {
  final authService = ref.read(authProvider);
  await authService.sendPasswordResetEmail(email);
});

