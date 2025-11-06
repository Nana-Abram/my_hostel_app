import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/hostels/hostels_card.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';


class AvailableRooms extends StatelessWidget {
  const AvailableRooms({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5.sw,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300, width: 0.5.w),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ROOM IMAGE
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            ),
            child: Image.asset(
              "assets/images/vegas1.jpg",
              width: 0.20.sw,
              height: 0.25.sh,
              fit: BoxFit.cover,
            ),
          ),

          /// ROOM DETAILS
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(40.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// TITLE + PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallText(
                        text: "Single Room",
                        color: Colors.black,
                        size: 13.sp,
                      ),
                      SmallText(
                        text: "GHS 3,000",
                        color: AppColors.blueColor,
                        size: 13.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  /// CAPACITY + PER SEMESTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconAndTextWidget(
                        icon: Icons.people_alt_outlined,
                        text: "Capacity: 2 students",
                        iconColor: Colors.blueGrey,
                        textSize: 9.sp,
                      ),
                      SmallText(
                        text: "Per semester",
                        color: Colors.black54,
                        size: 10.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  /// ROOM FEATURES
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: [
                      SmallContainerAndText(
                        containerColor: Colors.grey.shade50,
                        text: "Bed",
                        textColor: Colors.blueGrey,
                      ),
                      SmallContainerAndText(
                        containerColor: Colors.grey.shade50,
                        text: "Desk",
                        textColor: Colors.blueGrey,
                      ),
                      SmallContainerAndText(
                        containerColor: Colors.grey.shade50,
                        text: "Wardrobe",
                        textColor: Colors.blueGrey,
                      ),
                      SmallContainerAndText(
                        containerColor: Colors.grey.shade50,
                        text: "Fan",
                        textColor: Colors.blueGrey,
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  /// STATUS + BOOK BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallContainerAndText(
                        containerColor: AppColors.instantColor,
                        text: "Available",
                        textColor: Colors.green,
                        textSize: 10.sp,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/booking_page');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: SmallText(
                            text: "Book Now",
                            color: Colors.white,
                            size: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
