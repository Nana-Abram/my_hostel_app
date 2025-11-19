// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/users_provider.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/Utility/user_action_handler.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/users_widgets/users_header.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/users_widgets/users_list.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/users_widgets/users_stat.dart';


class UsersManagementPage extends ConsumerStatefulWidget {
  final Function(int) onIndexChanged;

  const UsersManagementPage({super.key, required this.onIndexChanged});

  @override
  ConsumerState<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends ConsumerState<UsersManagementPage> {
  final UserActionsHandler _actionsHandler = UserActionsHandler();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _actionsHandler.context = context;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Users Management',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              _buildUsersFilter(),
            ],
          ),
          SizedBox(height: 20.h),

          // USERS STATS
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(usersStatsProvider);
              return statsAsync.when(
                data: (stats) => UsersStats(stats: stats),
                loading: () => _buildStatsLoading(),
                error: (error, stack) => _buildStatsError(error),
              );
            },
          ),
          SizedBox(height: 24.h),

          // SEARCH AND ACTIONS
          UsersHeader(
            onBulkAction: (action) => _handleBulkAction(action, ref),
            onSearch: (query) => _handleSearch(query, ref),
          ),
          SizedBox(height: 16.h),

          // USERS LIST
          Consumer(
            builder: (context, ref, child) {
              final usersAsync = ref.watch(usersProvider);
              return usersAsync.when(
                data: (users) => UsersList(
                  users: users,
                  onUserAction: (action, user) => _handleUserAction(action, user, ref),
                ),
                loading: () => _buildUsersLoading(),
                error: (error, stack) => _buildUsersError(error, ref),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersFilter() {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 18.w, color: Colors.blueGrey),
          SizedBox(width: 8.w),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'All',
              items: ['All', 'Students', 'Hostel Owners', 'Admins']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                // TODO: implement filter behavior using provider/ref
              },
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
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

  Widget _buildUsersLoading() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              'Loading users...',
              style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersError(Object error, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48.w, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Failed to load users',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              ref.refresh(usersProvider);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _handleBulkAction(String action, WidgetRef ref) {
    switch (action) {
      case 'refresh':
        ref.refresh(usersProvider);
        ref.refresh(usersStatsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data refreshed')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export feature coming soon')),
        );
        break;
      case 'verify':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bulk verify feature coming soon')),
        );
        break;
    }
  }

  void _handleSearch(String query, WidgetRef ref) {
    // TODO: Implement search functionality
  }

  void _handleUserAction(String action, UserModel user, WidgetRef ref) {
    _actionsHandler.handleUserAction(action, user, ref);
  }
}