import 'package:flutter/material.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/pages/analytics_page.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/pages/hostels_page.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/pages/main_dashboard_page.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/pages/settings_page.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/pages/users_page.dart';


class AdminDashboard extends StatefulWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const AdminDashboard({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<AdminDashboard> createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    switch (widget.currentIndex) {
      case 0:
        return MainDashboard(onIndexChanged: widget.onIndexChanged);
      case 1:
        return UsersManagementPage(onIndexChanged: widget.onIndexChanged);
      case 2:
        return HostelsManagementPage();
      case 3:
        return AnalyticsPage();
      case 4:
        return SettingsPage();
      default:
        return MainDashboard(onIndexChanged: widget.onIndexChanged);
    }
  }
}