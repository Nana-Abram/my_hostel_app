import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UsersStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const UsersStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    final cards = [
      _buildStatCard(theme: theme, title: 'Total Users', value: '${stats['totalUsers'] ?? 0}', icon: Icons.people_outline, color: theme.colorScheme.primary, change: '+12%'),
      _buildStatCard(theme: theme, title: 'Students', value: '${stats['students'] ?? 0}', icon: Icons.school_outlined, color: theme.colorScheme.secondary, change: '+8%'),
      _buildStatCard(theme: theme, title: 'Hostel Owners', value: '${stats['hostelOwners'] ?? 0}', icon: Icons.business_outlined, color: theme.colorScheme.tertiary, change: '+15%'),
      _buildStatCard(theme: theme, title: 'Admins', value: '${stats['admins'] ?? 0}', icon: Icons.admin_panel_settings_outlined, color: theme.colorScheme.error, change: '+0%'),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            Expanded(child: cards[0]),
            SizedBox(width: 12.w),
            Expanded(child: cards[1]),
          ]),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(child: cards[2]),
            SizedBox(width: 12.w),
            Expanded(child: cards[3]),
          ]),
        ],
      );
    }

    return Row(children: [
      Expanded(child: cards[0]),
      SizedBox(width: 12.w),
      Expanded(child: cards[1]),
      SizedBox(width: 12.w),
      Expanded(child: cards[2]),
      SizedBox(width: 12.w),
      Expanded(child: cards[3]),
    ]);
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    final isPositive = change.startsWith('+');
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 18.w, color: color),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isPositive
                      ? theme.colorScheme.secondary.withValues(alpha: 0.12)
                      : theme.colorScheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isPositive
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
