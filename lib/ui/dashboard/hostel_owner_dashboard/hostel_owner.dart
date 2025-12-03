import 'package:flutter/material.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/bookings_page.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/dashboard_page.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/earnings_page.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/my_hostels_page.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/profile_page.dart';



class HostelOwnerDashboard extends StatefulWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const HostelOwnerDashboard({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<HostelOwnerDashboard> createState() => HostelOwnerDashboardState();
}

class HostelOwnerDashboardState extends State<HostelOwnerDashboard> {
  @override
  Widget build(BuildContext context) {
    switch (widget.currentIndex) {
      case 0:
        return DashboardPage(onIndexChanged: widget.onIndexChanged);
      case 1:
        return MyHostelsPage();
      case 2:
        return OwnerBookingsPage();
      case 3:
        return EarningsPage();
      case 4:
        return ProfilePage();
      default:
        return DashboardPage(onIndexChanged: widget.onIndexChanged);
    }
  }
}