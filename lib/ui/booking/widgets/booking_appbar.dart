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
  Size get preferredSize => Size.fromHeight(120.h);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      height: isMobile ? 64 : 120.h,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40.w),
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
          // Logo
          GestureDetector(
            onTap: () => context.go('/'),
            child: Row(
              children: [
                Container(
                  width: isMobile ? 32 : 40.w,
                  height: isMobile ? 32 : 40.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 10.r),
                  ),
                  child: Center(
                    child: Text(
                      'H',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!isMobile) ...[
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
              ],
            ),
          ),

          // Auth section
          _buildAuthSection(context, currentUser, isMobile),
        ],
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context, UserModel? currentUser, bool isMobile) {
    final theme = Theme.of(context);

    if (currentUser == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isMobile
              ? _mobileButton(context, "Login", false, () => context.push('/login'))
              : ElvButtonWidget(text: "Login", onPressed: () => context.push('/login')),
          SizedBox(width: isMobile ? 8 : 16.w),
          isMobile
              ? _mobileButton(context, "Sign Up", true, () => context.push('/signup'))
              : ElvButtonWidget(
                  text: "Sign Up",
                  onPressed: () => context.push('/signup'),
                  isPrimary: true,
                ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMobile) ...[
          Text(
            'Hi, ${currentUser.fullName.split(' ').first}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(width: 12.w),
        ],
        UserAvatar(
          user: currentUser,
          size: isMobile ? 32 : 40,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _mobileButton(BuildContext context, String text, bool isPrimary, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isPrimary ? theme.colorScheme.primary : Colors.transparent,
          border: Border.all(
            color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
