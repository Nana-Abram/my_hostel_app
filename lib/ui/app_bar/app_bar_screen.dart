import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/about/about_screen.dart';
import 'package:my_hostel_app/ui/admin/add_hostels.dart';
import 'package:my_hostel_app/ui/contact/contact_screen.dart';
import 'package:my_hostel_app/ui/home/home_screen.dart';
import 'package:my_hostel_app/ui/hostels/hostel_screen.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/nav_button_widget.dart';



class AppBarScreen extends StatefulWidget {
  const AppBarScreen({super.key});

  @override
  State<AppBarScreen> createState() => AppBarScreenState();
}

class AppBarScreenState extends State<AppBarScreen> {
  int _selectedIndex = 0;

  // List of pages for each navigation button
  final List<Widget> _pages = const [
    AdminAddHostelPage(),
    HomeScreen(),
    HostelsScreen(),
    AboutScreen(),
    ContactScreen(),
  ];

  // Helper function to switch body
  void onNavSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: Container(
          height: 120.h,
          padding: EdgeInsets.symmetric(horizontal: 40.w),
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
              // ===== LEFT SIDE (LOGO + NAME) =====
              Row(
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

              // ===== CENTER (NAV LINKS) =====
              Row(
                children: [
                  NavButtonWidget(
                    text: 'Admin',
                    isActive: _selectedIndex == 0,
                    onPressed: () => onNavSelected(0),
                  ),
                  NavButtonWidget(
                    text: 'Home',
                    isActive: _selectedIndex == 1,
                    onPressed: () => onNavSelected(1),
                  ),
                  NavButtonWidget(
                    text: 'Hostels',
                    isActive: _selectedIndex == 2,
                    onPressed: () => onNavSelected(2),
                  ),
                  NavButtonWidget(
                    text: 'About',
                    isActive: _selectedIndex == 3,
                    onPressed: () => onNavSelected(3),
                  ),
                  NavButtonWidget(
                    text: 'Contact',
                    isActive: _selectedIndex == 4,
                    onPressed: () => onNavSelected(4),
                  ),
                ],
              ),

              // ===== RIGHT SIDE (BUTTONS) =====
              Row(
                children: [
                  ElvButtonWidget(text: "Login", onPressed: () {}),
                  SizedBox(width: 16.w),
                  ElvButtonWidget(
                    text: "Sign Up",
                    onPressed: () {},
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // This changes dynamically based on selected nav button
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
    );
  }
}
