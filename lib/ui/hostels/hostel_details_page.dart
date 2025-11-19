import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/hostels/available_rooms.dart';
import 'package:my_hostel_app/ui/hostels/booking_card.dart';
import 'package:my_hostel_app/ui/hostels/image_slider_h_d.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class HostelDetailsPage extends ConsumerWidget {
  const HostelDetailsPage({super.key, required this.hostel,});

  final HostelModel hostel;
  


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsByHostelProvider(hostel.id));

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
                  ElvButtonWidget(text: "Login", onPressed: () {
                     Navigator.pushNamed(context, AppRoutes.loginScreen);
                  }),
                  SizedBox(width: 16.w),
                  ElvButtonWidget(
                    text: "Sign Up",
                    onPressed: () {
                       Navigator.pushNamed(context, AppRoutes.signUpScreen);
                    },
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconAndTextWidget(
                icon: Icons.arrow_back_ios,
                text: 'Back to search',
                iconColor: Colors.blueGrey,
                isBackArrow: true,
              ),
              SizedBox(height: 20.h),

              // Image carousel
              HostelImageCarousel(images: hostel.images),
              SizedBox(height: 30.h),

              // Responsive layout for content
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  
                  if (isMobile) {
                    return _buildMobileLayout(roomsAsync);
                  } else {
                    return _buildDesktopLayout(roomsAsync);
                  }
                },
              ),

              // Location map
              SizedBox(height: 30.h),
              _buildLocationMap(),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(AsyncValue<List<dynamic>> roomsAsync) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Hostel details and rooms
        Expanded(
          flex: 2,
          child: _buildHostelDetailsAndRooms(roomsAsync),
        ),
        
        SizedBox(width: 30.w),
        
        // Right column - Booking cards
        Expanded(
          flex: 1,
          child: BookingCardWidget(
            hostel: hostel,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AsyncValue<List<dynamic>> roomsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHostelDetailsAndRooms(roomsAsync),
        SizedBox(height: 30.h),
        BookingCardWidget(
          hostel: hostel,
        ),
      ],
    );
  }

  Widget _buildHostelDetailsAndRooms(AsyncValue<List<dynamic>> roomsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hostel name and rating
        SmallText(text: hostel.name, color: Colors.black, size: 16.sp),
        SizedBox(height: 15.h),
        
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
        SizedBox(height: 30.h),

        // About section
        _buildAboutSection(),
        SizedBox(height: 20.h),

        // Amenities
        _buildAmenitiesSection(),
        SizedBox(height: 30.h),

        // Available rooms
        SmallText(text: "Available Rooms", color: Colors.black, size: 16.sp),
        SizedBox(height: 20.h),
        
        // Rooms list with proper loading/error states
        roomsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
                SizedBox(height: 10.h),
                SmallText(
                  text: "Failed to load rooms",
                  color: Colors.red,
                  size: 12.sp,
                ),
              ],
            ),
          ),
          data: (rooms) {
            if (rooms.isEmpty) {
              return _buildNoRoomsAvailable();
            }
            return Column(
              children: rooms
                  .map((room) => Padding(
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: AvailableRooms(room: room, hostel: hostel),
                  ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }


  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
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
            color: Colors.grey.shade300,
            blurRadius: 5.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigText(
            text: "About this hostel",
            color: Colors.black,
            size: 16.sp,
          ),
          SizedBox(height: 12.h),
          SmallText(
            text: hostel.description,
            size: 12.sp,
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Container(
      width: double.infinity,
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
            color: Colors.grey.shade300,
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
            size: 16.sp,
          ),
          SizedBox(height: 15.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            alignment: WrapAlignment.start,
            children: hostel.amenities.map((amenity) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _buildNoRoomsAvailable() {
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.hotel, size: 50.sp, color: Colors.grey),
          SizedBox(height: 15.h),
          BigText(
            text: "No rooms available",
            color: Colors.grey,
            size: 16.sp,
          ),
          SizedBox(height: 10.h),
          SmallText(
            text: "Check back later for new room listings",
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMap() {
    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.blueGrey.shade300,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 8.r,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 50.sp,
            color: Colors.white,
          ),
          SizedBox(height: 15.h),
          BigText(
            text: "Location on map",
            color: Colors.white,
          ),
          SizedBox(height: 10.h),
          SmallText(
            text: hostel.campus,
            color: Colors.white,
          ),
        ],
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
