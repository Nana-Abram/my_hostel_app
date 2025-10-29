import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElvButtonWidget extends StatefulWidget {
  const ElvButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = false,
  });

  final String text;
  final void Function()? onPressed;
  final bool isPrimary; // determines color scheme

  @override
  State<ElvButtonWidget> createState() => _ElvButtonWidgetState();
}

class _ElvButtonWidgetState extends State<ElvButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2563EB);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 45.h,
        decoration: BoxDecoration(
          color: widget.isPrimary
              ? (_isHovered ? primaryColor.withOpacity(0.85) : primaryColor)
              : (_isHovered ? Colors.grey.shade200 : Colors.white),
          border: Border.all(
            color: widget.isPrimary ? primaryColor : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.isPrimary
                ? Colors.white
                : (_isHovered ? primaryColor : Colors.grey.shade800),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
