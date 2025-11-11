import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/hostels/available_rooms.dart';
import 'package:my_hostel_app/ui/hostels/booking_card.dart';
import 'package:my_hostel_app/ui/hostels/image_slider_h_d.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class HostelDetailsPage extends StatelessWidget {
  const HostelDetailsPage({super.key, required this.hostel});

  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: Container(
          height: 120.h,
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ===== LEFT SIDE (LOGO + NAME) =====
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'H',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  const Text(
                    "HostelHub",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              // ===== RIGHT SIDE (BUTTONS) =====
              Row(
                children: [
                  ElvButtonWidget(text: "Login", onPressed: () {}),
                  SizedBox(width: 16.w),
                  ElvButtonWidget(
                    text: "Sign Up",
                    onPressed: () {},
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
        // margin: EdgeInsets.all(30.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconAndTextWidget(
                icon: Icons.arrow_back_ios,
                text: 'Back to search',
                iconColor: Colors.blueGrey,
                isBackArrow: true,
              ),
              SizedBox(height: 20.h),
              HostelImageCarousel(images: hostel.images),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      SmallText(text: hostel.name, color: Colors.black),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          IconAndTextWidget(
                            icon: Icons.star,
                            text: hostel.rating.toStringAsFixed(1),
                            iconColor: Colors.orange,
                            textColor: Colors.black,
                          ),
                          SizedBox(width: 5.w),
                          SmallText(text: "(${hostel.reviewsCount} reviews)"),
                          SizedBox(width: 10.w),
                          IconAndTextWidget(
                            icon: Icons.location_on_outlined,
                            text: hostel.campus,
                            iconColor: Colors.blueGrey,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        width: 0.5.sw,
                        padding: EdgeInsets.all(20.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 0.5.w,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.r,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BigText(
                              text: "About this hostel",
                              color: Colors.black,
                            ),
                            SizedBox(height: 10.h),
                            SmallText(text: hostel.description, size: 10.sp),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        width: 0.5.sw, // Increased width for better content fit
                        padding: EdgeInsets.all(20.sp), // Reduced padding
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 0.5.w,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300, // Softer shadow
                              blurRadius: 8.r,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BigText(
                              text: "Amenities",
                              color: Colors.black,
                              size: 14.sp, // Slightly larger for better hierarchy
                              // Added weight for emphasis
                            ),
                            SizedBox(height: 15.h),
                            Wrap(
                              spacing: 30.w, // Reduced horizontal spacing
                              runSpacing: 20.h, // Reduced vertical spacing
                              alignment: WrapAlignment.start,
                              children: hostel.amenities.map((amenity) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Important: don't take full width
                                    children: [
                                      Icon(
                                        _getAmenityIcon(amenity),
                                        size: 16.sp,
                                        color: Colors.blue.shade700,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        amenity,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),
                      SmallText(text: "Available Rooms", color: Colors.black),
                      SizedBox(height: 30.h),
                      AvailableRooms(),
                    ],
                  ),

                  BookingCardWidget(
                    price: "3000",
                    duration: "semester",
                    campus: "UENR campus",
                    availableRooms: "3",
                    ratings: "4.5",
                    onBook: () {},
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                width: 0.65.sw,
                height: 0.40.sh,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.blueGrey.shade300,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.r,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 50.sp,
                      color: Colors.black,
                    ),
                    Center(child: BigText(text: "Location on map")),
                  ],
                ),
              ),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }
}

class RowIconAndText extends StatelessWidget {
  const RowIconAndText({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.checkColor,
          ),
          child: Icon(icon, size: 22.sp, color: AppColors.blueColor),
        ),
        SizedBox(width: 10.w),
        SmallText(text: text, color: Colors.black),
      ],
    );
  }
}

//============================================
IconData _getAmenityIcon(String amenity) {
  final amenityLower = amenity.toLowerCase();
  
  if (amenityLower.contains('wi-fi')) return Icons.wifi;
  if (amenityLower.contains('parking')) return Icons.local_parking;
  if (amenityLower.contains('pool')) return Icons.pool;
  if (amenityLower.contains('gym')) return Icons.fitness_center;
  if (amenityLower.contains('air conditioning')) return Icons.ac_unit;
  if (amenityLower.contains('tv')) return Icons.tv;
  if (amenityLower.contains('kitchen')) return Icons.kitchen;
  if (amenityLower.contains('laundry')) return Icons.local_laundry_service;
  if (amenityLower.contains('security')) return Icons.security;
  if (amenityLower.contains('study room')) return Icons.menu_book;
  
  return Icons.check_circle; // default icon
}
