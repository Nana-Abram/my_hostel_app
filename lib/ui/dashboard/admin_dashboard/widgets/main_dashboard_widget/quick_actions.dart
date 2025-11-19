import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActions extends StatelessWidget {
  final List<QuickActionItem> actions;
  final Function(int) onActionTap;

  const QuickActions({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 16.w,
          runSpacing: 16.h,
          children: actions.map((action) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 30.w,
              child: _buildQuickActionCard(action),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickActionItem action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                action.icon,
                size: 20.w,
                color: action.color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              action.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              action.subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}