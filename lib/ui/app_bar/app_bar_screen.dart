import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/about%20us/about_screen.dart';
import 'package:my_hostel_app/ui/contact%20us/contact_screen.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/home/home_screen.dart';
import 'package:my_hostel_app/ui/hostels/hostel_screen.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/nav_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/user_avatar.dart';


class AppBarScreen extends ConsumerStatefulWidget {
  const AppBarScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  ConsumerState<AppBarScreen> createState() => AppBarScreenState();
}

class AppBarScreenState extends ConsumerState<AppBarScreen> {
  late int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    HostelsScreen(),
    AboutScreen(),
    ContactScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

 void onNavSelected(int index) {
  setState(() => _selectedIndex = index);
  
  if (index == 0) {
    GoRouter.of(context).goNamed('home');
  } else {
    GoRouter.of(context).goNamed('tabs', pathParameters: {'tabIndex': index.toString()});
  }
}

  @override
  Widget build(BuildContext context,) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:PreferredSize(
  preferredSize: Size.fromHeight(120.h),
  child: LayoutBuilder(
    builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 650;
      // ignore: unused_local_variable
      final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 950;

      return Container(
        height: 120.h,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.w : 40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ======================================================
            // LEFT — LOGO + NAME
            // ======================================================
            GestureDetector(
              onTap: () => GoRouter.of(context).go('/'),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'H',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  if (!isMobile) // hide name on mobile to preserve space
                    const Text(
                      "HostelHub",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
            ),

            // ======================================================
            // CENTER — NAV BUTTONS
            // ======================================================
            if (!isMobile)
              Row(
                children: [
                  NavButtonWidget(
                    text: 'Home',
                    isActive: _selectedIndex == 0,
                    onPressed: () => onNavSelected(0),
                  ),
                  NavButtonWidget(
                    text: 'Hostels',
                    isActive: _selectedIndex == 1,
                    onPressed: () => onNavSelected(1),
                  ),
                  NavButtonWidget(
                    text: 'About',
                    isActive: _selectedIndex == 2,
                    onPressed: () => onNavSelected(2),
                  ),
                  NavButtonWidget(
                    text: 'Contact',
                    isActive: _selectedIndex == 3,
                    onPressed: () => onNavSelected(3),
                  ),
                ],
              ),

            // ======================================================
            // RIGHT — MENU / AUTH / AVATAR
            // ======================================================
            Consumer(builder: (context, ref, child) {
              final authState = ref.watch(authProvider);
              final user = authState.value;

              // MOBILE → show hamburger menu
              if (isMobile) {
                return Row(
                  children: [
                    if (user != null)
                      _buildUserMenu(user),

                    SizedBox(width: 10.w),

                    IconButton(
                      icon: Icon(Icons.menu, size: 26.sp, color: Colors.black87),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ],
                );
              }

              // DESKTOP / TABLET → full menu
              return _buildRightSection(user);
            }),
          ],
        ),
      );
    },
  ),
),

      endDrawer: Drawer(
  child: SafeArea(
    child: Column(
      children: [
        DrawerHeader(
          child: Text(
            "Menu",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: const Text("Home"),
          onTap: () => onNavSelected(0),
        ),
        ListTile(
          title: const Text("Hostels"),
          onTap: () => onNavSelected(1),
        ),
        ListTile(
          title: const Text("About"),
          onTap: () => onNavSelected(2),
        ),
        ListTile(
          title: const Text("Contact"),
          onTap: () => onNavSelected(3),
        ),
      ],
    ),
  ),
),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
    );
  }
Widget _buildRightSection(UserModel? currentUser) {
  if (currentUser == null) {
    // Show login/signup buttons when not logged in
    return Row(
      children: [
        ElvButtonWidget(
          text: "Login", 
          onPressed: () {
            GoRouter.of(context).push('/login');
          },
        ),
        SizedBox(width: 16.w),
        ElvButtonWidget(
          text: "Sign Up",
          onPressed: () {
            GoRouter.of(context).push('/signup');
          },
          isPrimary: true,
        ),
      ],
    );
  }

  // Show user avatar with dropdown menu when logged in
  return Row(
    children: [
      GestureDetector(
        onTap: () {
          GoRouter.of(context).goNamed('dashboard');
        },
        child: IconAndTextWidget(
                icon: Icons.dashboard,
                text: 'View Dashboard',
                iconColor: Colors.lightBlueAccent,
                iconSize: 25,
                textSize: 13.sp,
                textColor: Colors.lightBlueAccent,
                
              ),
      ),
          SizedBox(width: 0.1.sw),
      // User greeting (optional)
      Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getGreeting(currentUser),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade800,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              currentUser.fullName,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.blueGrey.shade600,
              ),
            ),
            if (currentUser.role == UserRole.admin)
              Container(
                margin: EdgeInsets.only(top: 2.h),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if(currentUser.role ==UserRole.hostelOwner)
                 Container(
                margin: EdgeInsets.only(top: 2.h),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Hostel owner',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 )
          ],    
        ),
      ),
      
      // User avatar with dropdown - FIXED
      _buildUserMenu(currentUser),
    ],
  );
}



// Separate method for user menu
Widget _buildUserMenu(UserModel currentUser) {
  return PopupMenuButton<String>(
    offset: Offset(0, 50.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    itemBuilder: (context) => _buildUserMenuItems(currentUser),
    onSelected: (value) => _handleUserMenuSelection(value, context),
    child:  Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.blueColor,
          width: 1.5.w,
        ),
      ),
      child: IgnorePointer(
        // This prevents ImageNetwork from intercepting taps
        child: UserAvatar(
          user: currentUser,
          size: 45,
          // Don't pass onTap here
        ),
      )
    )
  );
}


  List<PopupMenuEntry<String>> _buildUserMenuItems(UserModel user) {
    final items = <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        value: 'profile',
        child: Row(
          children: [
            Icon(Icons.person, size: 18.sp, color: Colors.blueGrey),
            SizedBox(width: 8.w),
            Text('My Profile', style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
    ];

    if (user.role == UserRole.admin) {
      items.addAll([
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'manage_hostels',
          child: Row(
            children: [
              Icon(Icons.apartment, size: 18.sp, color: Colors.blue),
              SizedBox(width: 8.w),
              Text('Manage Hostels', style: TextStyle(fontSize: 12.sp, color: Colors.blue)),
            ],
          ),
        ),
      ]);
    }

    items.addAll([
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'logout',
        child: Row(
          children: [
            Icon(Icons.logout, size: 18.sp, color: Colors.red),
            SizedBox(width: 8.w),
            Text('Logout', style: TextStyle(fontSize: 12.sp, color: Colors.red)),
          ],
        ),
      ),
    ]);

    return items;
  }

  void _handleUserMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'profile':
        GoRouter.of(context).push('/profile');
        break;
      case 'manage_hostels':
        GoRouter.of(context).goNamed('dashboard');
        break;
      case 'logout':
        _handleLogout(context);
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout', style: TextStyle(fontSize: 16.sp)),
        content: Text('Are you sure you want to logout?', style: TextStyle(fontSize: 12.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Get auth notifier from context
                final authNotifier = ref.read(authProvider.notifier);
                await authNotifier.signOut();
                GoRouter.of(context).go('/');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
            child: Text('Logout', style: TextStyle(fontSize: 12.sp, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getGreeting(UserModel user) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
