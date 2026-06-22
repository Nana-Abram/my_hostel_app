// ignore_for_file: unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/widgets/modern/image_widgets.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/provider/notification_provider.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/admin_dashboard.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/pages/settings_page.dart';
import 'package:my_hostel_app/ui/dashboard/edit_profile_page.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/hostel_owner.dart';
import 'package:my_hostel_app/ui/dashboard/student_dashboard/student_dashboard.dart';
import 'package:my_hostel_app/ui/notifications/notification_center_screen.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  void _editProfile() {
    final authState = ref.read(authProvider);
    final currentUser = authState.value;

    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(currentUser: currentUser),
        ),
      ).then((updatedUser) {
        if (updatedUser != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return authState.when(
      // ── The GoRouter redirect now handles unauthenticated navigation,
      //    so this data: branch only has to deal with the happy path.
      data: (user) {
        if (user == null) {
          // GoRouter redirect will kick in on the next frame; show a blank
          // loader rather than scheduling a navigation inside build.
          return _buildLoadingScreen(theme);
        }
        // Start Firestore real-time notification listener for this user.
        ref.watch(notificationListenerProvider(user.id));
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _buildAppBar(user, context, theme),
          body: _buildBody(user),
          bottomNavigationBar: _buildBottomNavigationBar(user, theme),
        );
      },
      loading: () => _buildLoadingScreen(theme),
      error: (error, stack) => _buildErrorScreen(error, theme),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(UserModel user, BuildContext context, ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 1,
      title: Row(
        children: [
          Tooltip(
            message: 'Back to home',
            child: IconAndTextWidget(
                icon: Icons.arrow_back_ios,
                iconColor: theme.colorScheme.onSurfaceVariant,
                isBackArrow: true,
                
              ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                'H',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HostelHub',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final countAsync =
                ref.watch(unreadNotificationsCountProvider(user.id));
            final count = countAsync.asData?.value ?? 0;
            return IconButton(
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text(count > 99 ? '99+' : '$count'),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 24.w,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationCenterScreen(userId: user.id),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Tooltip(
            message: 'Profile Menu',
            child: CircleAvatar(
              radius: 18.w,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: user.profileImage != null
                  ? EnhancedCachedImage(
                      key: ValueKey(user.profileImage),
                      imageUrl: user.profileImage!,
                      height: 36.w,
                      width: 36.w,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(18.w),
                      errorWidget: Icon(
                        Icons.error,
                        color: theme.colorScheme.error,
                      ),
                      onTap: _showProfileMenu,
                    )
                  : InkWell(
                      onTap: _showProfileMenu,
                      child: Text(
                        user.fullName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(UserModel user) {
    switch (user.role) {
      case UserRole.admin:
        return AdminDashboard(
          currentIndex: _currentIndex,
          onIndexChanged: (index) => setState(() => _currentIndex = index),
        );
      case UserRole.hostelOwner:
        return HostelOwnerDashboard(
          currentIndex: _currentIndex,
          onIndexChanged: (index) => setState(() => _currentIndex = index),
        );
      case UserRole.student:
        return const StudentDashboard();
      default:
        return const StudentDashboard();
    }
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNavigationBar(UserModel user, ThemeData theme) {
    if (user.role == UserRole.student) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        selectedLabelStyle:
            TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 11.sp),
        items: _getNavigationItems(user.role),
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Hostels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ];

      case UserRole.hostelOwner:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'My Hostels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];

      case UserRole.student:
      default:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ── Profile bottom sheet ──────────────────────────────────────────────────

  void _showProfileMenu() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile header
              Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(authProvider).value;
                  return user != null
                      ? _buildProfileHeader(user, theme)
                      : const SizedBox();
                },
              ),
              SizedBox(height: 20.h),

              _buildMenuButton(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                theme: theme,
                onTap: () {
                  Navigator.pop(context);
                  _editProfile();
                },
              ),
              _buildMenuButton(
                icon: Icons.settings_outlined,
                title: 'Settings',
                theme: theme,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SettingsPage(isAppBarVisible: true),
                    ),
                  );
                },
              ),
              _buildMenuButton(
                icon: Icons.help_outline,
                title: 'Help & Support',
                theme: theme,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Help & Support coming soon.'),
                      backgroundColor: const Color(0xFF323232),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
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
      },
    );
  }

  Widget _buildProfileHeader(UserModel user, ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24.w,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: user.profileImage != null
              ? EnhancedCachedImage(
                  key: ValueKey(user.profileImage),
                  imageUrl: user.profileImage!,
                  height: 48.w,
                  width: 48.w,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(24.w),
                  errorWidget: Icon(
                    Icons.error,
                    color: theme.colorScheme.error,
                  ),
                )
              : Text(
                  user.fullName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role, theme).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  user.role.displayName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getRoleColor(user.role, theme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 24.w,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20.w,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Color _getRoleColor(UserRole role, ThemeData theme) {
    switch (role) {
      case UserRole.admin:
        return Colors.orange;
      case UserRole.hostelOwner:
        return Colors.purple;
      case UserRole.student:
      default:
        return theme.colorScheme.primary;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  void _confirmLogout() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Log Out',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _logout();
              // GoRouter redirect will automatically send the user to /login
              // once Firebase auth state emits null — no manual navigation needed.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      // The GoRouter redirect watches authStateProvider and will automatically
      // navigate to /login once the stream emits null. No manual go() needed.
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  // ── Loading / Error screens ───────────────────────────────────────────────

  Widget _buildLoadingScreen(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            SizedBox(height: 20.h),
            Text(
              'Loading your dashboard...',
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object error, ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.w,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: 20.h),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: () => ref.refresh(authProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
