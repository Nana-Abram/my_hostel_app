import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HostelOwnerDashboard extends StatefulWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const HostelOwnerDashboard({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<HostelOwnerDashboard> createState() => _HostelOwnerDashboardState();
}

class _HostelOwnerDashboardState extends State<HostelOwnerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Hostel Owner Dashboard - Page ${widget.currentIndex + 1}',
        style: TextStyle(fontSize: 20.sp),
      ),
    );
  }
}