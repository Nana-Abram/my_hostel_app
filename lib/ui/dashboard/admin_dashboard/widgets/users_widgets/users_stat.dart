import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UsersStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const UsersStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildUserStatCard(
            title: 'Total Users',
            value: '${stats['totalUsers'] ?? 0}',
            icon: Icons.people_outline,
            color: Colors.blue,
            change: '+12%',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildUserStatCard(
            title: 'Students',
            value: '${stats['students'] ?? 0}',
            icon: Icons.school_outlined,
            color: Colors.green,
            change: '+8%',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildUserStatCard(
            title: 'Hostel Owners',
            value: '${stats['hostelOwners'] ?? 0}',
            icon: Icons.business_outlined,
            color: Colors.orange,
            change: '+15%',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildUserStatCard(
            title: 'Admins',
            value: '${stats['admins'] ?? 0}',
            icon: Icons.admin_panel_settings_outlined,
            color: Colors.purple,
            change: '+0%',
          ),
        ),
      ],
    );
  }

  Widget _buildUserStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    final isPositive = change.startsWith('+');
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.w, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              change,
              style: TextStyle(
                fontSize: 12.sp,
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}