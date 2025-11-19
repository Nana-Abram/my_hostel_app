import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/users_provider.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/main_dashboard_widget/quick_actions.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/main_dashboard_widget/recent_activity.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/main_dashboard_widget/stats_grid.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/main_dashboard_widget/welcome_header.dart';
// import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/users_widgets/users_stat.dart';


class MainDashboard extends ConsumerWidget {
  final Function(int) onIndexChanged;

  const MainDashboard({super.key, required this.onIndexChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final stats = ref.watch(usersStatsProvider);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WelcomeHeader(),
          SizedBox(height: 30.h),
          
             // USERS STATS
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(usersStatsProvider);
              return statsAsync.when(
                data: (stats) => StatsGrid(stats: stats),
                loading: () => _buildStatsLoading(),
                error: (error, stack) => _buildStatsError(error),
              );
            },
          ),


          SizedBox(height: 30.h),
          _buildRecentActivity(),
          SizedBox(height: 30.h),
          _buildQuickActions(),
        ],
      ),
    );
  }


  
  Widget _buildStatsLoading() {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          if (i < 3) SizedBox(width: 12.w),
        ],
      ],
    );
  }

  Widget _buildStatsError(Object error) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Failed to load stats: $error',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }


  // Widget _buildStatsGrid() {

  //    // USERS STATS
  //         Consumer(
  //           builder: (context, ref, child) {
  //             final statsAsync = ref.watch(usersStatsProvider);
  //             return statsAsync.when(
  //               data: (stats) => UsersStats(stats: stats),
  //               loading: () => _buildStatsGrid(),
  //               error: (error, stack) => _buildStatsGrid(),
  //             );
  //           },
  //         );
  //   final stats = [
  //     StatItem(
  //       title: 'Total Users',
  //       value:"45",
  //       change: '+12%',
  //       isPositive: true,
  //       icon: Icons.people,
  //       color: Colors.blue,
  //     ),
  //     StatItem(
  //       title: 'Total Hostels',
  //       value: '89',
  //       change: '+5%',
  //       isPositive: true,
  //       icon: Icons.business,
  //       color: Colors.green,
  //     ),
  //     StatItem(
  //       title: 'Bookings',
  //       value: '324',
  //       change: '+8%',
  //       isPositive: true,
  //       icon: Icons.book_online,
  //       color: Colors.orange,
  //     ),
  //     StatItem(
  //       title: 'Revenue',
  //       value: 'GHS 24,580',
  //       change: '+15%',
  //       isPositive: true,
  //       icon: Icons.attach_money,
  //       color: Colors.purple,
  //     ),
  //   ];

  //   return StatsGrid(stats: stats);
  // }

  Widget _buildRecentActivity() {
    final activities = [
      ActivityItem(
        user: 'Osei Frank',
        action: 'Booked a room',
        time: '2 min ago',
        type: 'booking',
        icon: Icons.book_online,
        color: Colors.green,
      ),
      ActivityItem(
        user: 'Godbless Ghansah',
        action: 'Created new hostel',
        time: '15 min ago',
        type: 'hostel',
        icon: Icons.business,
        color: Colors.blue,
      ),
      ActivityItem(
        user: 'Saaka Ahmed',
        action: 'Updated profile',
        time: '1 hour ago',
        type: 'profile',
        icon: Icons.person,
        color: Colors.orange,
      ),
      ActivityItem(
        user: 'Emily Davis',
        action: 'Cancelled booking',
        time: '2 hours ago',
        type: 'cancellation',
        icon: Icons.cancel,
        color: Colors.red,
      ),
    ];

    return RecentActivity(activities: activities);
  }

  Widget _buildQuickActions() {
    final actions = [
      QuickActionItem(
        title: 'Manage Users',
        subtitle: 'View and manage all users',
        icon: Icons.people,
        color: Colors.blue,
        onTap: () => onIndexChanged(1),
      ),
      QuickActionItem(
        title: 'Verify Hostels',
        subtitle: 'Approve new hostel listings',
        icon: Icons.verified,
        color: Colors.green,
        onTap: () => onIndexChanged(2),
      ),
      QuickActionItem(
        title: 'View Reports',
        subtitle: 'Platform analytics & insights',
        icon: Icons.analytics,
        color: Colors.orange,
        onTap: () => onIndexChanged(3),
      ),
      QuickActionItem(
        title: 'System Settings',
        subtitle: 'Platform configuration',
        icon: Icons.settings,
        color: Colors.purple,
        onTap: () => onIndexChanged(4),
      ),
    ];

    return QuickActions(actions: actions, onActionTap: onIndexChanged);
  }
}