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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(24.h),
        width: 280.w,
        height: 250.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isHovered ? Colors.blue.shade50 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(_isHovered ? 0.6 : 0.3),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: _isHovered ? Colors.blueAccent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Box
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: widget.containerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 32.w,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              widget.firstText,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            SmallText(
              text: widget.secondText,
              size: 11.sp,
              color: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }
}
