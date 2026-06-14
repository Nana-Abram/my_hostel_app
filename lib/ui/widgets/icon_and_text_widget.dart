import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class IconAndTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double textSize;
  final Color textColor;
  final bool isBackArrow;

  final Color iconColor;
  const IconAndTextWidget({
    super.key,
    required this.icon,
    this.text = '',
    required this.iconColor,
    this.iconSize = 20,
    this.textSize = 16,
    this.textColor = Colors.blueGrey,
    this.isBackArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: [
          Center(
            child: isBackArrow
                ? GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        // If there's a previous page, go back
                        context.pop();
                      } else {
                        // If this is the first page, go to home
                        GoRouter.of(context).goNamed('tabs', pathParameters: {'tabIndex':1.toString()});
                      }
                    },
                    child: Icon(icon, color: iconColor, size: iconSize),
                  )
                : Icon(icon, color: iconColor, size: iconSize),
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(fontSize: textSize, color: textColor),
          ),
        ],
      ),
    );
  }
}
