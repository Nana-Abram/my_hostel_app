import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UsersStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const UsersStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildUserStatCard(
            context: context,
            title: 'Total Users',
            value: '${stats['totalUsers'] ?? 0}',
            icon: Icons.people_outline,
            color: theme.colorScheme.primary,
            change: '+12%',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildUserStatCard(
            context: context,
            title: 'Students',
            value: '${stats['students'] ?? 0}',
            icon: Icons.school_outlined,
            color: theme.colorScheme.secondary,
            change: '+8%',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildUserStatCard(
            context: context,
            title: 'Hostel Owners',
            value: '${stats['hostelOwners'] ?? 0}',
            icon: Icons.business_outlined,
            color: theme.colorScheme.tertiary,
            change: '+15%',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildUserStatCard(
            context: context,
            title: 'Admins',
            value: '${stats['admins'] ?? 0}',
            icon: Icons.admin_panel_settings_outlined,
            color: theme.colorScheme.error,
            change: '+0%',
          ),
        ),
      ],
    );
  }

  Widget _buildUserStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    final theme = Theme.of(context);
    final isPositive = change.startsWith('+');
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
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
              color: color.withValues(alpha: 0.1),
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
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isPositive ? theme.colorScheme.secondary.withValues(alpha: 0.12) : theme.colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              change,
              style: TextStyle(
                fontSize: 12.sp,
                color: isPositive ? theme.colorScheme.secondary : theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}