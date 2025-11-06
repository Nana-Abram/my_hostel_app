import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';

class BookingCardWidget extends StatelessWidget {
  final String price;
  final String duration;
  final String campus;
  final String ratings;
  final String availableRooms;
  final VoidCallback onBook;

  const BookingCardWidget({
    super.key,
    required this.price,
    required this.duration,
    required this.campus,
    required this.ratings,
    required this.availableRooms,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.25.sw,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .15),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SmallText(text: "Starting from", color: Colors.black54), 
           BigText(text: "GHS $price", color: AppColors.blueColor, size: 16.sp),
           SmallText(text: "Per semester", color: Colors.black54), 
          SizedBox(height: 10.h,),
          Divider(height: 20.h, color: Colors.grey.shade300),
          SizedBox(height: 10.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallText(text: "Campus", color: Colors.black54),
              SmallText(text: campus, color: Colors.black, size: 12.sp),
            ],
          ),
           SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallText(text: "Duration", color: Colors.black54),        
          SmallText(text: duration, color: Colors.black, size: 12.sp),
            ],
          ),
           SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
           
          SmallText(text: "Available rooms", color: Colors.black54),
         
          BigText(text: availableRooms, color:Colors.black, size: 12.sp),

            ],
          ),
           SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
           
          SmallText(text: "Ratings", color: Colors.black54),
          IconAndTextWidget(icon: Icons.star, text: ratings, iconColor:AppColors.orangeColor, textColor:Colors.black ,)

            ],
          ),

          SizedBox(height: 25.h),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/booking_page');
              },
              child: ElvButtonWidget(
                text: "Book Now",
                isPrimary: true,
                onPressed: onBook,
              ),
            ),
          ),

          SizedBox(height: 10.h),
          Center(
            child: SmallText(
              text: "You won’t be charged yet",
              color: Colors.black45,
              size: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
