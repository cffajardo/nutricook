import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/core/validators.dart';
import 'package:nutricook/features/auth/providers/auth_provider.dart';
import 'package:nutricook/features/profile/provider/user_provider.dart';
import 'package:nutricook/routing/app_routes.dart';
import 'package:nutricook/services/r2_upload_service.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _initialized = false;
  bool _savingUsername = false;
  bool _savingEmail = false;
  bool _sendingReset = false;
  bool _updatingPhoto = false;
  bool _deletingAccount = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).asData?.value;
    final uid = ref.watch(currentUserIdProvider);
    final isGoogleSignInUser =
        user?.providerData.any((p) => p.providerId == 'google.com') == true;

    if (uid == null || user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF9FA),
          elevation: 0,
          title: const Text('Edit Profile'),
        ),
        body: const Center(child: Text('Please sign in again.')),
      );
    }

    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9FA),
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: userDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load profile: $error')),
        data: (userData) {
          final username =
              (userData?['username'] ?? user.displayName ?? '').toString();
          final email = (userData?['email'] ?? user.email ?? '').toString();
          final photoUrl =
              (userData?['mediaId'] ?? userData?['profilePictureUrl'] ?? user.photoURL)
                  ?.toString();

          if (!_initialized) {
            _usernameController.text = username;
            _emailController.text = email;
            _initialized = true;
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _buildPhotoCard(photoUrl: photoUrl),
              const SizedBox(height: 16),
              _buildAccountCard(
                uid: uid,
                currentUsername: username,
                currentEmail: email,
                isGoogleSignInUser: isGoogleSignInUser,
              ),
              const SizedBox(height: 16),
              _buildDangerZone(uid: uid),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard({String? photoUrl}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.rosePink, width: 2),
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.cardRose,
              backgroundImage:
                  photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 42, color: AppColors.rosePink)
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _updatingPhoto ? null : _changeProfilePicture,
              icon: _updatingPhoto
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_camera_outlined),
              label: Text(_updatingPhoto ? 'Updating photo...' : 'Change Profile Picture'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rosePink,
                side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required String uid,
    required String currentUsername,
    required String currentEmail,
    required bool isGoogleSignInUser,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rosePink.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savingUsername
                  ? null
                  : () => _updateUsername(uid: uid, currentUsername: currentUsername),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rosePink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_savingUsername ? 'Saving...' : 'Save Username'),
            ),
          ),
          if (!isGoogleSignInUser) ...[
            const SizedBox(height: 18),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Changing email sends a verification link to the new address.',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savingEmail
                    ? null
                    : () => _updateEmail(uid: uid, currentEmail: currentEmail),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosePink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_savingEmail ? 'Updating...' : 'Change Email'),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _sendingReset ? null : _sendPasswordReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rosePink,
                side: BorderSide(color: AppColors.rosePink.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_sendingReset ? 'Sending...' : 'Send Password Reset Email'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone({required String uid}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danger Zone',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deleting your account is permanent and cannot be undone.',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _deletingAccount ? null : () => _deleteAccount(uid),
              icon: const Icon(Icons.delete_forever_rounded),
              label: Text(_deletingAccount ? 'Deleting...' : 'Delete Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _changeProfilePicture() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() => _updatingPhoto = true);
    try {
      final r2Service = R2UploadService();
      final imageUrl = await r2Service.uploadImage(
        imageXFile: picked,
        folder: 'users',
      );

      await ref.read(userServiceProvider).updateProfilePictureUrl(uid, imageUrl);
      await ref.read(authProvider).updatePhotoUrl(imageUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Profile picture updated.')),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Failed to update picture: $e')),
        );
    } finally {
      if (mounted) setState(() => _updatingPhoto = false);
    }
  }

  Future<void> _updateUsername({
    required String uid,
    required String currentUsername,
  }) async {
    final candidate = _usernameController.text.trim();
    if (candidate == currentUsername.trim()) {
      _showMessage('Username is unchanged.');
      return;
    }
    if (!isValidUsername(candidate)) {
      _showMessage('Username must be at least 3 chars (letters, numbers, underscore).');
      return;
    }

    setState(() => _savingUsername = true);
    try {
      final taken = await ref
          .read(userServiceProvider)
          .isUsernameTaken(candidate, excludeUid: uid);

      if (taken) {
        _showMessage('That username is already in use.');
        return;
      }

      await ref.read(userServiceProvider).updateUserProfile(uid, {
        'username': candidate,
      });
      await ref.read(authProvider).updateDisplayName(candidate);
      _showMessage('Username updated.');
    } catch (e) {
      _showMessage('Failed to update username: $e');
    } finally {
      if (mounted) setState(() => _savingUsername = false);
    }
  }

  Future<void> _updateEmail({
    required String uid,
    required String currentEmail,
  }) async {
    final candidate = _emailController.text.trim();
    if (candidate == currentEmail.trim()) {
      _showMessage('Email is unchanged.');
      return;
    }
    if (!isValidEmail(candidate)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    setState(() => _savingEmail = true);
    try {
      await ref.read(authProvider).verifyBeforeUpdateEmail(candidate);
      await ref.read(userServiceProvider).updateUserProfile(uid, {'email': candidate});
      _showMessage('Verification link sent to your new email.');
    } catch (e) {
      _showMessage('Failed to change email: $e');
    } finally {
      if (mounted) setState(() => _savingEmail = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = ref.read(authStateProvider).asData?.value?.email;
    if (email == null || email.isEmpty) {
      _showMessage('No email on this account.');
      return;
    }

    setState(() => _sendingReset = true);
    try {
      await ref.read(authProvider).sendPasswordResetEmail(email);
      _showMessage('Password reset email sent.');
    } catch (e) {
      _showMessage('Failed to send reset email: $e');
    } finally {
      if (mounted) setState(() => _sendingReset = false);
    }
  }

  Future<void> _deleteAccount(String uid) async {
    final controller = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type DELETE to confirm. This action cannot be undone.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim() == 'DELETE'),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    controller.dispose();

    if (confirm != true) return;

    setState(() => _deletingAccount = true);
    try {
      await ref.read(userServiceProvider).deleteUserAccountWithOwnedData(uid);
      await ref.read(authProvider).deleteCurrentUser();

      if (!mounted) return;
      context.go(AppRoutes.loginPath);
    } catch (e) {
      _showMessage('Failed to delete account: $e');
    } finally {
      if (mounted) setState(() => _deletingAccount = false);
    }
  }
}
