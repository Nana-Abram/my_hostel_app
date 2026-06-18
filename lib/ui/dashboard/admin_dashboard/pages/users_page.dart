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
  ConsumerState<UsersManagementPage> createState() =>
      _UsersManagementPageState();
}

class _UsersManagementPageState extends ConsumerState<UsersManagementPage> {
  final UserActionsHandler _actionsHandler = UserActionsHandler();

  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _actionsHandler.context = context;
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<UserModel> _applyFilters(List<UserModel> users) {
    var result = users;

    // Role filter
    if (_selectedFilter != 'All') {
      result = result.where((u) {
        switch (_selectedFilter) {
          case 'Students':
            return u.role == UserRole.student;
          case 'Hostel Owners':
            return u.role == UserRole.hostelOwner;
          case 'Admins':
            return u.role == UserRole.admin;
          default:
            return true;
        }
      }).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((u) =>
              u.fullName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          // Page header
          if (isMobile) ...[
            Text(
              'Users Management',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            _buildRoleFilter(theme),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Users Management',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                _buildRoleFilter(theme),
              ],
            ),
          SizedBox(height: 20.h),

          // STATS
          Consumer(
            builder: (context, ref, child) {
              final statsAsync = ref.watch(usersStatsProvider);
              return statsAsync.when(
                data: (stats) => UsersStats(stats: stats),
                loading: () => _buildStatsLoading(theme),
                error: (error, stack) => _buildStatsError(error, theme),
              );
            },
          ),
          SizedBox(height: 24.h),

          // SEARCH + BULK ACTIONS
          UsersHeader(
            onBulkAction: _handleBulkAction,
            onSearch: (query) => setState(() => _searchQuery = query),
          ),
          SizedBox(height: 16.h),

          // USERS LIST
          Consumer(
            builder: (context, ref, child) {
              final usersAsync = ref.watch(usersProvider);
              return usersAsync.when(
                data: (users) {
                  final filtered = _applyFilters(users);
                  if (filtered.isEmpty) return _buildEmptyState(theme);
                  return UsersList(
                    users: filtered,
                    onUserAction: (action, user) =>
                        _actionsHandler.handleUserAction(action, user, ref),
                  );
                },
                loading: () => _buildUsersLoading(theme),
                error: (error, stack) => _buildUsersError(error, theme),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Filter dropdown ───────────────────────────────────────────────────────

  Widget _buildRoleFilter(ThemeData theme) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, size: 18.w,
              color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 8.w),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              dropdownColor: theme.colorScheme.surface,
              items: ['All', 'Students', 'Hostel Owners', 'Admins']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: theme.colorScheme.onSurface,
                            )),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedFilter = value);
              },
              style: TextStyle(
                  fontSize: 13.sp, color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(ThemeData theme) {
    final isFiltered = _selectedFilter != 'All' || _searchQuery.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 56.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          SizedBox(height: 16.h),
          Text(
            isFiltered ? 'No users match your filter' : 'No users yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (isFiltered) ...[
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => setState(() {
                _selectedFilter = 'All';
                _searchQuery = '';
              }),
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }

  // ── Loading / Error helpers ───────────────────────────────────────────────

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
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary),
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
          Icon(Icons.error_outline,
              color: theme.colorScheme.onErrorContainer, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Failed to load stats: $error',
              style: TextStyle(
                  color: theme.colorScheme.onErrorContainer, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersLoading(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            SizedBox(height: 16.h),
            Text('Loading users...',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersError(Object error, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline,
              size: 48.w, color: theme.colorScheme.error),
          SizedBox(height: 16.h),
          Text('Failed to load users',
              style: TextStyle(
                  fontSize: 16.sp, fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
          SizedBox(height: 8.h),
          Text(error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurfaceVariant)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => ref.invalidate(usersProvider),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── Bulk actions ──────────────────────────────────────────────────────────

  void _handleBulkAction(String action) {
    switch (action) {
      case 'refresh':
        ref.invalidate(usersProvider);
        ref.invalidate(usersStatsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data refreshed')),
        );
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export feature coming soon')),
        );
      case 'verify':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bulk verify feature coming soon')),
        );
    }
  }
}
