import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentDashboard extends StatefulWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const StudentDashboard({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Student Dashboard - Page ${widget.currentIndex + 1}',
        style: TextStyle(fontSize: 20.sp),
      ),
    );
  }
}