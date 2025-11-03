
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconAndTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final double  iconSize;
  final double textSize;
  final Color textColor;
  final bool isBackArrow;

  final Color iconColor;
  const IconAndTextWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor,
    this.iconSize =20,
    this.textSize = 16,
    this.textColor = Colors.blueGrey,
    this.isBackArrow = false


    });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            isBackArrow?Navigator.pop(context):null;
          },
          child: Icon(icon, color: iconColor,size: iconSize)),
        SizedBox(width: 5.w,),
        Text(text, style: TextStyle(fontSize:textSize , color: textColor),)
      ],
    );
  }
}