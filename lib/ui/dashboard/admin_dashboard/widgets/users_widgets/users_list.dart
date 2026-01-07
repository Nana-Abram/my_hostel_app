import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/ui/dashboard/admin_dashboard/widgets/users_widgets/users_list_items.dart';


class UsersList extends StatelessWidget {
  final List<UserModel> users;
  final Function(String, UserModel) onUserAction;

  const UsersList({
    super.key,
    required this.users,
    required this.onUserAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (users.isEmpty) {
      return _buildEmptyUsersState(theme);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // TABLE HEADER
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                SizedBox(width: 40.w), // Avatar space
                Expanded(
                  flex: 2,
                  child: Text(
                    'User',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Role',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Last Login',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(width: 80.w), // Actions space
              ],
            ),
          ),

          // USERS LIST
          ...users.map((user) => UserListItem(
            user: user,
            onAction: onUserAction,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyUsersState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 64.w, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(height: 16.h),
          Text(
            'No Users Found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'There are no users in the system yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}