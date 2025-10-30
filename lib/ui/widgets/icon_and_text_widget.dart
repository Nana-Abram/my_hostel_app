
import 'package:flutter/material.dart';
import 'package:my_hostel_app/ui/core/dimensions.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class IconAndTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  final Color iconColor;
  const IconAndTextWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor
    });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor,size: Dimensions.iconSize24,),
        SizedBox(width: 5,),
        SmallText(text: text)
      ],
    );
  }
}