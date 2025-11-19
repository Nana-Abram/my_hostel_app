// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/users_provider.dart';


class UserActionsHandler {
  BuildContext? context;

  void handleUserAction(String action, UserModel user, WidgetRef ref) async {
    if (context == null) return;

    final usersService = UsersService();
    
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _editUser(user, ref);
        break;
      case 'verify':
        try {
          await usersService.verifyUser(user.id);
          ref.refresh(usersProvider);
          _showSnackBar('User verified successfully');
        } catch (e) {
          _showSnackBar('Failed to verify user: $e');
        }
        break;
      case 'promote':
        try {
          await usersService.updateUserRole(user.id, UserRole.admin);
          ref.refresh(usersProvider);
          _showSnackBar('User promoted to admin');
        } catch (e) {
          _showSnackBar('Failed to promote user: $e');
        }
        break;
      case 'message':
        _sendMessageToUser(user);
        break;
      case 'delete':
        _deleteUser(user, ref);
        break;
    }
  }

  void _showUserDetails(UserModel user) {
    if (context == null) return;

    showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _editUser(UserModel user, WidgetRef ref) {
    if (context == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${user.fullName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _showSnackBar('User update requested for ${nameController.text}');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _sendMessageToUser(UserModel user) {
    if (context == null) return;

    final messageController = TextEditingController();

    showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: Text('Send Message to ${user.fullName}'),
          content: TextField(
            controller: messageController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Enter your message'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final message = messageController.text.trim();
                if (message.isEmpty) {
                  _showSnackBar('Please enter a message before sending');
                  return;
                }
                Navigator.of(context).pop();
                _showSnackBar('Message sent to ${user.fullName}');
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(UserModel user, WidgetRef ref) async {
    if (context == null) return;

    final usersService = UsersService();
    
    showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await usersService.deleteUser(user.id);
                ref.refresh(usersProvider);
                _showSnackBar('User deleted successfully');
              } catch (e) {
                _showSnackBar('Failed to delete user: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return _formatDate(date);
  }
}