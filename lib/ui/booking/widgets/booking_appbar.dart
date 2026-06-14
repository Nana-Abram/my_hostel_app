import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/user_avatar.dart';

class BookingAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const BookingAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;

    return PreferredSize(
      preferredSize: Size.fromHeight(120.h),
      child: Container(
        height: 120.h,
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo and brand name
            GestureDetector(
              onTap: () => context.go('/'),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'H',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "HostelHub",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // Auth section - shows avatar if logged in, buttons if not
            _buildAuthSection(context, currentUser),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context, UserModel? currentUser) {
    final theme = Theme.of(context);
    if (currentUser == null) {
      // Show auth buttons when not logged in
      return Row(
        children: [
          ElvButtonWidget(
            text: "Login", 
            onPressed: () {
              context.push('/login');
            },
          ),
          SizedBox(width: 16.w),
          ElvButtonWidget(
            text: "Sign Up",
            onPressed: () {
              context.push('/signup');
            },
            isPrimary: true,
          ),
        ],
      );
    }

    // Show user avatar when logged in
    return Row(
      children: [
        Text(
          'Hi, ${currentUser.fullName.split(' ').first}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(width: 12.w),
        UserAvatar(
          user: currentUser,
          size: 40,
          onTap: () {
            // Optional: Navigate to profile
            // context.push('/profile');
          },
        ),
      ],
    );
  }

    @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}