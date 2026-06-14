import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/users_provider.dart';

class UsersHeader extends ConsumerStatefulWidget {
  final Function(String) onBulkAction;
  final Function(String) onSearch;

  const UsersHeader({
    super.key,
    required this.onBulkAction,
    required this.onSearch,
  });

  @override
  ConsumerState<UsersHeader> createState() => _UsersHeaderState();
}

class _UsersHeaderState extends ConsumerState<UsersHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // SEARCH BAR
          Expanded(
            child: Container(
              height: 45.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.w,
                      color: theme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 13.sp,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                      onChanged: widget.onSearch,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        widget.onSearch('');
                      },
                      child: Icon(Icons.close, size: 16.w,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // REFRESH BUTTON
          IconButton(
            onPressed: () {
              ref.invalidate(usersProvider);
              ref.invalidate(usersStatsProvider);
            },
            icon: Icon(Icons.refresh, size: 20.w, color: theme.colorScheme.primary),
            tooltip: 'Refresh',
          ),

          // BULK ACTIONS MENU
          PopupMenuButton<String>(
            onSelected: widget.onBulkAction,
            color: theme.colorScheme.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Text('Export Users',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
              ),
              PopupMenuItem(
                value: 'verify',
                child: Text('Bulk Verify',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh Data',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
              ),
            ],
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.more_vert, size: 18.w,
                  color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
