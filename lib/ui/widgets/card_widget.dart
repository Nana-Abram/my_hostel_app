import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class CardWidget extends StatefulWidget {
  const CardWidget({
    super.key,
    required this.firstText,
    required this.secondText,
    required this.icon,
    required this.containerColor,
    required this.iconColor,
  });

  final String firstText;
  final String secondText;
  final IconData icon;
  final Color iconColor;
  final Color containerColor;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(isMobile ? 0 : 16.w),
        padding: EdgeInsets.all(isMobile ? 20 : 24.h),
        width: double.infinity,
        height: isMobile ? null : 250.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isHovered ? theme.colorScheme.primary.withValues(alpha: 0.08) : theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: _isHovered ? 0.12 : 0.06),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: _isHovered ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Box
            Container(
              width: isMobile ? 52 : 60.w,
              height: isMobile ? 52 : 60.h,
              decoration: BoxDecoration(
                color: widget.containerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: isMobile ? 28 : 32.w,
              ),
            ),
            SizedBox(height: isMobile ? 14 : 20.h),
            Text(
              widget.firstText,
              style: TextStyle(
                fontSize: isMobile ? 14 : 13.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SmallText(
              text: widget.secondText,
              size: isMobile ? 12 : 11.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
