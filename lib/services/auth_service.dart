import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isGoogleSignInInitialized = false;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with either username or email. If the identifier contains '@',
  /// treats it as email. Otherwise looks up the email from the username in Firestore.
  Future<void> signInWithUsernameOrEmail({
    required String usernameOrEmail,
    required String password,
  }) async {
    final identifier = usernameOrEmail.trim();
    String email;

    if (identifier.contains('@')) {
      email = identifier;
    } else {
      email = await _getEmailByUsername(identifier);
    }

    await signInWithEmail(email: email, password: password);
  }

  Future<String> _getEmailByUsername(String username) async {
    final snapshot = await _db
        .collection(FirestoreConstants.users)
        .where('username', isEqualTo: username.trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No user found with this username.');
    }

    final email = snapshot.docs.first.data()['email'] as String?;
    if (email == null || email.isEmpty) {
      throw Exception('User account has no email.');
    }
    return email;
  }

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _createUserDocument(
        uid: userCredential.user!.uid,
        email: email.trim(),
        username: username.trim(),
        profilePictureUrl: null,
      );

      await userCredential.user!.updateDisplayName(username.trim());

      // Send verification email so user can prove they own the address
      await userCredential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          username: userCredential.user!.displayName ?? 'Google User',
          profilePictureUrl: userCredential.user!.photoURL,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _initializeGoogleSignIn();
      await _googleSignIn.signOut();
      
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) return;
    await _googleSignIn.initialize();
    _isGoogleSignInInitialized = true;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sends a verification link to the current user's email.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('You must be signed in to verify your email.');
    if (user.email == null || user.email!.isEmpty) {
      throw Exception('No email address to verify.');
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Reloads the current user from Firebase to get the latest emailVerified status.
  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String username,
    String? profilePictureUrl,
  }) async {
    await _db.collection('users').doc(uid).set({
      'id': uid,
      'email': email,
      'username': username,
      'mediaId': profilePictureUrl,
      'allergens': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}