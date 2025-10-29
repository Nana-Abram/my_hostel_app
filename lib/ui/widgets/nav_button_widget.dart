import 'package:flutter/material.dart';
import 'package:my_hostel_app/ui/core/dimensions.dart';

class NavButtonWidget extends StatefulWidget {
  const NavButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.isActive = false,
  });

  final String text;
  final void Function()? onPressed;
  final bool isActive;

  @override
  State<NavButtonWidget> createState() => _NavButtonWidgetState();
}

class _NavButtonWidgetState extends State<NavButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? Colors.blueAccent
        : (_isHovered ? Colors.blueAccent : Colors.grey.shade700);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            border: widget.isActive
                ? Border(
                    bottom: BorderSide(width: 2, color: Colors.blueAccent),
                  )
                : null,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: Dimensions.fontMedium16,
              fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
