import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({super.key, required this.user, this.size = 40, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (user == null) {
      return _buildPlaceholderAvatar(theme);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2.w),
        ),
        child: Stack(
          children: [
            // Profile image if available
            if (user!.profileImage != null && user!.profileImage!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(size.w),
                child: ImageNetwork(
                  image: user!.profileImage!,
                  height: size.w,
                  width: size.w,
                  onError: _buildInitialsAvatar(user!, theme),
                  onTap: onTap,
                ),
              )
            else
              _buildInitialsAvatar(user!, theme),

            // Online indicator for admin/active users
            if (user!.role == UserRole.admin)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50), // green
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 2.w),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(UserModel user, ThemeData theme) {
    return Center(
      child: Text(
        _getUserInitials(user),
        style: TextStyle(
          fontSize: (size * 0.35).sp,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border.all(color: theme.dividerColor, width: 2.w),
        ),
        child: Icon(
          Icons.person_outline,
          size: (size * 0.5).sp,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _getUserInitials(UserModel user) {
    if (user.fullName.isNotEmpty) {
      final names = user.fullName.split(' ');
      if (names.length > 1) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }

    if (user.email.isNotEmpty) {
      return user.email[0].toUpperCase();
    }

    return 'U';
  }
}
