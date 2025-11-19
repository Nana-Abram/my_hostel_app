// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/users_provider.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';

class UsersHeader extends ConsumerWidget {
  final Function(String) onBulkAction;
  final Function(String) onSearch;

  const UsersHeader({
    super.key,
    required this.onBulkAction,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController();
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
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
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18.w, color: Colors.blueGrey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search users...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: TextStyle(fontSize: 12.sp),
                      onChanged: onSearch,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // REFRESH BUTTON
          IconButton(
            onPressed: () {
              ref.refresh(usersProvider);
              ref.refresh(usersStatsProvider);
            },
            icon: Icon(Icons.refresh, size: 20.w, color: AppColors.blueColor),
            tooltip: 'Refresh',
          ),

          // ACTIONS
          PopupMenuButton<String>(
            onSelected: onBulkAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'export', child: Text('Export Users')),
              const PopupMenuItem(value: 'verify', child: Text('Bulk Verify')),
              const PopupMenuItem(value: 'refresh', child: Text('Refresh Data')),
            ],
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.more_vert, size: 18.w, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}