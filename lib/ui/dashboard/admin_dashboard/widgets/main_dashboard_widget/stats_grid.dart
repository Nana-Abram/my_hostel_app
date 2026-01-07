import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
  spacing: 20.w,
  runSpacing: 20.h,
  children: [
    SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 30.w,
      child: _buildUserStatCard(
        theme: theme,
        title: 'Total Users',
        value: '${stats['totalUsers'] ?? 0}',
        icon: Icons.people_outline,
        color: Colors.blue,
        change: '+12%',
      ),
    ),
    SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 30.w,
      child: _buildUserStatCard(
        theme: theme,
        title: 'Total Hostels',
        value: '${stats['totalHostels'] ?? 0}',
        icon: Icons.school_outlined,
        color: Colors.green,
        change: '+8%',
      ),
    ),
    SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 30.w,
      // height: 200.h,
      child: _buildUserStatCard(
        theme: theme,
        title: 'Bookings',
        value: '${stats['totalBookings'] ?? 0}',
        icon: Icons.business_outlined,
        color: Colors.orange,
        change: '+15%',
      ),
    ),
    SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 30.w,
      child: _buildUserStatCard(
        theme: theme,
        title: 'Revenue',
        value: 'GHS ${stats['totalEarnings'] ?? 0}',
        icon: Icons.attach_money,
        color: Colors.purple,
        change: '+10%',
      ),
    ),
  ],
);

  }

  Widget _buildUserStatCard({
    required ThemeData theme,
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
        color: theme.colorScheme.surface,
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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