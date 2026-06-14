import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/users_provider.dart';

class UserActionsHandler {
  BuildContext? context;

  bool get _isMounted => context != null && context!.mounted;

  void handleUserAction(String action, UserModel user, WidgetRef ref) {
    if (!_isMounted) return;

    switch (action) {
      case 'view':
        _showUserDetails(user);
      case 'edit':
        _editUser(user, ref);
      case 'verify':
        _verifyUser(user, ref);
      case 'promote':
        _promoteUser(user, ref);
      case 'message':
        _sendMessageToUser(user);
      case 'delete':
        _deleteUser(user, ref);
    }
  }

  // ── View ──────────────────────────────────────────────────────────────────

  void _showUserDetails(UserModel user) {
    if (!_isMounted) return;
    showDialog(
      context: context!,
      builder: (ctx) => AlertDialog(
        title: Text(user.fullName),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Email: ${user.email}'),
              SizedBox(height: 8.h),
              Text('Role: ${user.role.displayName}'),
              SizedBox(height: 8.h),
              Text('Status: ${user.isEmailVerified ? 'Verified' : 'Unverified'}'),
              if (user.lastLogin != null) ...[
                SizedBox(height: 8.h),
                Text('Last login: ${_formatTimeAgo(user.lastLogin!)}'),
              ],
              SizedBox(height: 8.h),
              Text('Joined: ${_formatDate(user.createdAt)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ── Edit ──────────────────────────────────────────────────────────────────

  void _editUser(UserModel user, WidgetRef ref) {
    if (!_isMounted) return;

    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final usersService = UsersService();

    showDialog(
      context: context!,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${user.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              if (name.isEmpty || email.isEmpty) {
                _showSnackBar('Name and email cannot be empty');
                return;
              }
              Navigator.of(ctx).pop();
              try {
                await usersService.updateUser(user.id, {
                  'fullName': name,
                  'email': email,
                });
                if (!_isMounted) return;
                ref.invalidate(usersProvider);
                _showSnackBar('$name updated successfully');
              } catch (e) {
                if (!_isMounted) return;
                _showSnackBar('Failed to update user: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Verify ────────────────────────────────────────────────────────────────

  Future<void> _verifyUser(UserModel user, WidgetRef ref) async {
    if (!_isMounted) return;
    final confirmed = await showDialog<bool>(
      context: context!,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify User'),
        content: Text('Mark ${user.fullName} as verified?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await UsersService().verifyUser(user.id);
      if (!_isMounted) return;
      ref.invalidate(usersProvider);
      ref.invalidate(usersStatsProvider);
      _showSnackBar('${user.fullName} verified successfully');
    } catch (e) {
      if (!_isMounted) return;
      _showSnackBar('Failed to verify user: $e');
    }
  }

  // ── Promote ───────────────────────────────────────────────────────────────

  Future<void> _promoteUser(UserModel user, WidgetRef ref) async {
    try {
      await UsersService().updateUserRole(user.id, UserRole.admin);
      if (!_isMounted) return;
      ref.invalidate(usersProvider);
      _showSnackBar('${user.fullName} promoted to admin');
    } catch (e) {
      if (!_isMounted) return;
      _showSnackBar('Failed to promote user: $e');
    }
  }

  // ── Message ───────────────────────────────────────────────────────────────

  void _sendMessageToUser(UserModel user) {
    if (!_isMounted) return;
    final messageController = TextEditingController();

    showDialog(
      context: context!,
      builder: (ctx) => AlertDialog(
        title: Text('Message ${user.fullName}'),
        content: TextField(
          controller: messageController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Enter your message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final message = messageController.text.trim();
              if (message.isEmpty) {
                _showSnackBar('Please enter a message before sending');
                return;
              }
              Navigator.of(ctx).pop();
              _showSnackBar('Messaging is not available yet.');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  void _deleteUser(UserModel user, WidgetRef ref) {
    if (!_isMounted) return;
    final theme = Theme.of(context!);

    showDialog(
      context: context!,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await UsersService().deleteUser(user.id);
                if (!_isMounted) return;
                ref.invalidate(usersProvider);
                _showSnackBar('${user.fullName} deleted successfully');
              } catch (e) {
                if (!_isMounted) return;
                _showSnackBar('Failed to delete user: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    if (_isMounted) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _formatDate(date);
  }
}
