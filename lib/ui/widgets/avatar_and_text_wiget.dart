import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class AvatarAndTextWiget extends StatelessWidget {
  const AvatarAndTextWiget({
    super.key,
    required this.circleText,
    required this.color,
    required this.firstText,
    required this.secondText,
    this.avatarRadius = 45,
    this.isBold = true,
    this.needsDivider = false


  });
  final String circleText;
  final Color color;
  final String firstText;
  final String secondText;
  final double avatarRadius;
  final bool isBold;
  final bool needsDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         needsDivider? Row(
            children: [
               CircleAvatar(
            radius: avatarRadius,
            backgroundColor: color,
            child: Text(circleText, style: TextStyle(fontSize: 18.sp, fontWeight:FontWeight.bold, color: theme.colorScheme.onPrimary),),
          ),
          SizedBox(width: 10,),
           SizedBox(
                width: 0.08.sw,
                child: Divider(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1,
                  thickness: 3,
                
                ),
              )
            
            ],
          ):
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: color,
            child: Text(circleText, style: TextStyle(fontSize: 18.sp, fontWeight:FontWeight.bold, color: theme.colorScheme.onPrimary),),
          ),
          SizedBox(height: 10.h),
      
          Text(
            firstText,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight:isBold?FontWeight.bold:null,
              color:isBold? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SmallText(text: secondText, size: 11.sp, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
