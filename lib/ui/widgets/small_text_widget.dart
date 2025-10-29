
// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:my_hostel_app/ui/core/dimensions.dart';

// ignore: must_be_immutable
class SmallText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;
  TextOverflow overFlow;


  SmallText({
    super.key,
    required this.text,
    this.color= Colors.blueGrey,
    this.size = 0,
    this.height = 1.2,
    this.overFlow = TextOverflow.ellipsis

    
    });

  @override
  Widget build(BuildContext context) {
    return Text(

      text,
      maxLines: 1,
      overflow: overFlow,
      style: TextStyle(
        fontSize:size == 0?Dimensions.fontSmall12:size, fontWeight: FontWeight.w400,height: height,color: color
      ),
    );
  }
}