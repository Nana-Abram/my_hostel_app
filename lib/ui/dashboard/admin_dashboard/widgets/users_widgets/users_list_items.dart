import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final Function(String, UserModel) onAction;

  const UserListItem({
    super.key,
    required this.user,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final lastLogin = user.lastLogin != null 
        ? _formatTimeAgo(user.lastLogin!)
        : 'Never';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // AVATAR
      CircleAvatar(
  radius: 20.w,
  backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
  child: user.profileImage != null
      ? ClipOval(
          child: ImageNetwork(
            image: user.profileImage!,
            height: 40.w,             // Match diameter of CircleAvatar
            width: 40.w,
            fitAndroidIos: BoxFit.cover,
            fitWeb: BoxFitWeb.cover,
            backgroundColor: Colors.transparent,
            onLoading: const CircularProgressIndicator(color: Colors.indigoAccent),
            onError: const Icon(Icons.error, color: Colors.red),
          ),
        )
      : Text(
          user.fullName[0],
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: _getRoleColor(user.role),
          ),
        ),
),
 
          SizedBox(width: 12.w),

          // USER INFO
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    if (user.isEmailVerified)
                      Icon(Icons.verified, size: 14.w, color: Colors.blue),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Joined ${_formatDate(user.createdAt)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // ROLE
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 60.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                user.role.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // STATUS
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: user.isEmailVerified ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  user.isEmailVerified ? 'Verified' : 'Unverified',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: user.isEmailVerified ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // LAST LOGIN
          Expanded(
            child: Text(
              lastLogin,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blueGrey,
              ),
            ),
          ),

          // ACTIONS
          SizedBox(
            width: 80.w,
            child: PopupMenuButton<String>(
              onSelected: (value) => onAction(value, user),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16.w, color: Colors.blueGrey),
                      SizedBox(width: 8.w),
                      const Text('View Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16.w, color: Colors.blue),
                      SizedBox(width: 8.w),
                      const Text('Edit User'),
                    ],
                  ),
                ),
                if (!user.isEmailVerified)
                  PopupMenuItem(
                    value: 'verify',
                    child: Row(
                      children: [
                        Icon(Icons.verified, size: 16.w, color: Colors.green),
                        SizedBox(width: 8.w),
                        const Text('Verify'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'message',
                  child: Row(
                    children: [
                      Icon(Icons.message, size: 16.w, color: Colors.orange),
                      SizedBox(width: 8.w),
                      const Text('Send Message'),
                    ],
                  ),
                ),
                if (user.role != UserRole.admin)
                  PopupMenuItem(
                    value: 'promote',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 16.w, color: Colors.orange),
                        SizedBox(width: 8.w),
                        const Text('Promote to Admin'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16.w, color: Colors.red),
                      SizedBox(width: 8.w),
                      const Text('Delete User'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.more_vert, size: 16.w, color: Colors.blueGrey),
              ),
            ),
          ),
        ],
      ),
    );
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Colors.blue;
      case UserRole.hostelOwner:
        return Colors.orange;
      case UserRole.admin:
        return Colors.purple;
      // ignore: unreachable_switch_default
      default:
        return Colors.grey;
    }
  }
}