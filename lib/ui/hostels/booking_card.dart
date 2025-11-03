import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';

class BookingCardWidget extends StatelessWidget {
  final String price;
  final String duration;
  final String roomType;
  final VoidCallback onBook;

  const BookingCardWidget({
    super.key,
    required this.price,
    required this.duration,
    required this.roomType,
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
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigText(text: "Booking Summary", color: Colors.black, size: 14.sp),
          Divider(height: 20.h, color: Colors.grey.shade300),

          SmallText(text: "Room Type", color: Colors.black54),
          SizedBox(height: 4.h),
          SmallText(text: roomType, color: Colors.black, size: 12.sp),
          SizedBox(height: 15.h),

          SmallText(text: "Duration", color: Colors.black54),
          SizedBox(height: 4.h),
          SmallText(text: duration, color: Colors.black, size: 12.sp),
          SizedBox(height: 15.h),

          SmallText(text: "Total Price", color: Colors.black54),
          SizedBox(height: 4.h),
          BigText(
            text: "GHS $price",
            color: AppColors.blueColor,
            size: 16.sp,
          ),

          SizedBox(height: 25.h),
          Center(
            child: ElvButtonWidget(
              text: "Book Now",
              isPrimary: true,
              onPressed: onBook,
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
