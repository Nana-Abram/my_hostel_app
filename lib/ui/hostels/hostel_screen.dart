import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/hostels/filter_section.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class HostelsScreen extends StatelessWidget {
  const HostelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40.h, left: 80.w),
      color: Color(0XFFF9FAFB),
      child:SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h,),
          BigText(text: "Available Hostels", size: 18.sp,),
          SizedBox(height: 10.h,),
          SmallText(text: "Found 6 hostels matching your criteria"),
          SizedBox(height: 20.h,),
            
          SizedBox(
            height: 0.85.sh,
            child: Row(
              children: [
                FilterSection()
              ],
            ),
          ),
          SizedBox(height: 60.h,)
        ],
            ),
      ) ,
    );
  }
}