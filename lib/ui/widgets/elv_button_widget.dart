import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElvButtonWidget extends StatefulWidget {
  const ElvButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isFilter=false
  });

  final String text;
  final void Function()? onPressed;
  final bool isPrimary; 
  final bool isFilter;
  // determines color scheme

  @override
  State<ElvButtonWidget> createState() => _ElvButtonWidgetState();
}

class _ElvButtonWidgetState extends State<ElvButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 45.h,
          decoration: widget.isFilter?
           BoxDecoration(
            color: widget.isPrimary
                ? (_isHovered ? primaryColor.withValues(alpha: 0.85) : primaryColor)
                : (_isHovered ? theme.colorScheme.primary.withValues(alpha: 0.08) : theme.colorScheme.surface),
            border:(_isHovered? Border.all(
              color: widget.isPrimary ? primaryColor : theme.colorScheme.outline,
            ):null),
            borderRadius: (_isHovered?BorderRadius.circular(10.r):null),
          ):
           BoxDecoration(
            color: widget.isPrimary
                ? (_isHovered ? primaryColor.withValues(alpha: 0.85) : primaryColor)
                : (_isHovered ? theme.colorScheme.primary.withValues(alpha: 0.08) : theme.colorScheme.surface),
            border:Border.all(
              color: widget.isPrimary ? primaryColor : theme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
        
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          alignment: Alignment.center,
          
          
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.isPrimary 
                  ? theme.colorScheme.onPrimary
                  : widget.isFilter ? theme.colorScheme.primary :
                  (_isHovered ? primaryColor : theme.colorScheme.onSurface),
              fontSize:widget.isFilter?10.sp: 16.sp,
              fontWeight:widget.isFilter?null:FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
