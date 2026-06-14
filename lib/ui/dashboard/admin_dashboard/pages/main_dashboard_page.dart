import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/users_provider.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/main_dashboard_widget/quick_actions.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/main_dashboard_widget/recent_activity.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/main_dashboard_widget/stats_grid.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/main_dashboard_widget/welcome_header.dart';

class MainDashboard extends ConsumerWidget {
  final Function(int) onIndexChanged;

  const MainDashboard({super.key, required this.onIndexChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          const WelcomeHeader(),
          SizedBox(height: 30.h),

          // USERS STATS
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(usersStatsProvider);
              return statsAsync.when(
                data: (stats) => StatsGrid(stats: stats),
                loading: () => _buildStatsLoading(theme),
                error: (error, stack) => _buildStatsError(error, theme),
              );
            },
          ),

          SizedBox(height: 30.h),
          _buildRecentActivity(theme),
          SizedBox(height: 30.h),
          _buildQuickActions(theme),
        ],
      ),
    );
  }

  Widget _buildStatsLoading(ThemeData theme) {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              ),
            ),
          ),
          if (i < 3) SizedBox(width: 12.w),
        ],
      ],
    );
  }

  Widget _buildStatsError(Object error, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Failed to load stats: $error',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final activities = [
      ActivityItem(
        user: 'Recent Activity',
        action: 'Live data coming soon',
        time: '',
        type: 'info',
        icon: Icons.info_outline,
        color: theme.colorScheme.primary,
      ),
    ];

    return RecentActivity(activities: activities);
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      QuickActionItem(
        title: 'Manage Users',
        subtitle: 'View and manage all users',
        icon: Icons.people,
        color: theme.colorScheme.primary,
        onTap: () => onIndexChanged(1),
      ),
      QuickActionItem(
        title: 'Verify Hostels',
        subtitle: 'Approve new hostel listings',
        icon: Icons.verified,
        color: theme.colorScheme.secondary,
        onTap: () => onIndexChanged(2),
      ),
      QuickActionItem(
        title: 'All Bookings',
        subtitle: 'Monitor platform bookings',
        icon: Icons.receipt_long,
        color: theme.colorScheme.tertiary,
        onTap: () => onIndexChanged(3),
      ),
    ];

    return QuickActions(actions: actions, onActionTap: onIndexChanged);
  }
}
