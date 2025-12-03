import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/pages/settings_page.dart';

class ProfileMenuSheet extends ConsumerWidget {
  const ProfileMenuSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const ProfileMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Header
          if (user != null) _buildProfileHeader(user),

          SizedBox(height: 20.h),

          // Menu Items
          _buildMenuButton(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.pop(context);
              _editProfile(context);
            },
          ),
          _buildMenuButton(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(isAppBarVisible: true),
                ),
              );
            },
          ),
          _buildMenuButton(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          SizedBox(height: 16.h),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // UI COMPONENTS
  // -------------------------

  Widget _buildProfileHeader(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundImage: NetworkImage(user.profileImage!),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22.sp),
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // -------------------------
  // ACTION HANDLERS
  // -------------------------

  void _editProfile(BuildContext context) {
    // Navigate to edit profile page
  }

  void _confirmLogout(BuildContext context) {
    // Logout confirmation dialog
  }
}
