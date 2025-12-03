// ignore_for_file: unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/admin_dashboard.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/pages/settings_page.dart';
import 'package:my_hostel_app/ui/dashboard/edit_profile_page.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/hostel_owner.dart';
import 'package:my_hostel_app/ui/dashboard/student_dashboard/student_dashboard.dart';

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
        if (updatedUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load user data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Redirect to login if user is null
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          });
          return _buildLoadingScreen();
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(user),
          body: _buildBody(user),
          bottomNavigationBar: _buildBottomNavigationBar(user),
        );
      },
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(error),
    );
  }

  AppBar _buildAppBar(UserModel user) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          // Logo
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                'H',
                style: TextStyle(
                  color: Colors.white,
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
                  color: Colors.black87,
                ),
              ),
              Text(
                _getGreeting(),
                style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Notification Icon
        IconButton(
          icon: Badge(
            label: Text('3'), // You can make this dynamic
            child: Icon(Icons.notifications_outlined, size: 24.w),
          ),
          onPressed: () {
            // Navigate to notifications
          },
        ),

        // User Profile
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Tooltip(
            message: 'Profile Menu',
            child: CircleAvatar(
              radius: 18.w,
              backgroundColor: AppColors.blueColor.withOpacity(0.1),
              child: user.profileImage != null
                  ? ClipOval(
                      child: ImageNetwork(
                        image: user.profileImage!,
                        height: 36.w, // Diameter = radius * 2
                        width: 36.w,
                        fitAndroidIos: BoxFit.cover,
                        fitWeb: BoxFitWeb.cover,
                        backgroundColor: Colors.transparent,
                        onLoading: const CircularProgressIndicator(
                          color: Colors.indigoAccent,
                        ),
                        onError: const Icon(Icons.error, color: Colors.red),
                        onTap: _showProfileMenu,
                      ),
                    )
                  : InkWell(
                      onTap: _showProfileMenu,
                    child: Text(
                        user.fullName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueColor,
                        ),
                      ),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(UserModel user) {
    // Show different dashboard based on user role
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
        return StudentDashboard();
      default:
        return StudentDashboard();
    }
  }

  Widget _buildBottomNavigationBar(UserModel user) {
    final navItems = _getNavigationItems(user.role);
      if (user.role == UserRole.student) {
    return const SizedBox.shrink();
  }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.blueColor,
        unselectedItemColor: Colors.blueGrey,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11.sp),
        items: navItems,
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems(UserRole role) {
    
    switch (role) {
      case UserRole.admin:
        return [
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
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ];

      case UserRole.hostelOwner:
        return [
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
        return
         [
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Header
              Consumer(
                builder: (context, ref, child) {
                  final user = ref.watch(authProvider).value;
                  return user != null ? _buildProfileHeader(user) : SizedBox();
                },
              ),
              SizedBox(height: 20.h),

              // Menu Items
              _buildMenuButton(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap:(){
                 Navigator.pop(context);
                 _editProfile();
                }
              ),
              _buildMenuButton(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                 Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(isAppBarVisible: true,),
                      ),
                    );
                  // Navigate to settings
                },
              ),
              _buildMenuButton(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Navigator.pop(context);

                  // Navigate to help
                },
              ),
              SizedBox(height: 16.h),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Log Out'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Row(
      children: [
        // User Profile
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: CircleAvatar(
            radius: 18.w,
            backgroundColor: AppColors.blueColor.withOpacity(0.1),
            child: user.profileImage != null
                ? ClipOval(
                    child: ImageNetwork(
                      image: user.profileImage!,
                      height: 36.w, // Diameter = radius * 2
                      width: 36.w,
                      fitAndroidIos: BoxFit.cover,
                      fitWeb: BoxFitWeb.cover,
                      backgroundColor: Colors.transparent,
                      onLoading: const CircularProgressIndicator(
                        color: Colors.indigoAccent,
                      ),
                      onError: const Icon(Icons.error, color: Colors.red),
                    ),
                  )
                : Text(
                    user.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueColor,
                    ),
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
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                user.email,
                style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  user.role.displayName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getRoleColor(user.role),
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
  }) {
    return ListTile(
      leading: Icon(icon, size: 24.w, color: Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, color: Colors.black87),
      ),
      trailing: Icon(Icons.chevron_right, size: 20.w, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.orange;
      case UserRole.hostelOwner:
        return Colors.purple;
      case UserRole.student:
      default:
        return AppColors.blueColor;
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).goNamed('login'); // Close bottom sheet
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      // Auth state provider will handle the navigation
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.blueColor),
            SizedBox(height: 20.h),
            Text(
              'Loading your dashboard...',
              style: TextStyle(fontSize: 16.sp, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.w, color: Colors.red),
              SizedBox(height: 20.h),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: () => ref.refresh(authProvider),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
