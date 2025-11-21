import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/main.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/hostels/hostels_card.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class AvailableRooms extends StatelessWidget {
  const AvailableRooms({
    super.key,
    required this.room,
    required this.hostel,
    this.isHostelOwner = false,
  });

  final RoomModel room;
  final HostelModel hostel;
  final bool isHostelOwner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isHostelOwner ? 0.9.sw : 0.5.sw,
      height: isHostelOwner ? 300.h : 270.h,
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
            child: ImageNetwork(
              image: room.image,
              height: 355.h,
              width: isHostelOwner ? 440.w : 250.w,
              fitAndroidIos: BoxFit.cover,
              fitWeb: BoxFitWeb.cover,
            ),
          ),

          /// ROOM DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// TITLE + PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallText(
                        text: room.type,
                        color: Colors.black,
                        size: 13.sp,
                      ),

                      SmallText(
                        text: room.capacity == 1
                            ? "GHS${room.price.toStringAsFixed(2)}"
                            : "Per head: GHS${(room.price).toStringAsFixed(2)}",
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
                        text: room.capacity == 1
                            ? "Capacity: ${room.capacity} student"
                            : "Capacity: ${room.capacity} students",
                        iconColor: Colors.blueGrey,
                        textSize: 12.sp,
                      ),
                      SmallText(
                        text: "Per Year",
                        color: Colors.black54,
                        size: 12.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  /// ROOM FEATURES
                  Wrap(
                    spacing: 10.w, // Reduced horizontal spacing
                    runSpacing: 10.h, // Reduced vertical spacing
                    alignment: WrapAlignment.start,
                    children: room.features.map((feature) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Important: don't take full width
                          children: [
                            Icon(
                              _getFeatureIcon(feature),
                              size: 16.sp,
                              color: Colors.blue.shade700,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              feature,
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
                  SizedBox(height: 15.h),

                  /// STATUS + BOOK BUTTON
                  SmallContainerAndText(
                    containerColor: room.available
                        ? AppColors.instantColor
                        : Colors.blueGrey.shade50,
                    text: room.available ? "Available" : "Unavailable",
                    textColor: room.available ? Colors.green : Colors.black,
                    textSize: 12.sp,
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallText(
                        text: "Gender: ${room.gender}",
                        color: Colors.black54,
                        size: 12.sp,
                      ),
                      isHostelOwner?Container(): GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.bookingPage,
                            arguments: BookingArguments(
                              selectedRoom: room, // Required
                              selectedHostel: hostel, // Required
                            ),
                          );
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
                      )
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

IconData _getFeatureIcon(String feature) {
  final featureLower = feature.toLowerCase();

  if (featureLower.contains('bed')) return Icons.bed;
  if (featureLower.contains('desk')) return Icons.desk;
  if (featureLower.contains('fan')) return Icons.ac_unit;
  if (featureLower.contains('wardrobe')) return Icons.business;
  if (featureLower.contains('air conditioning')) return Icons.ac_unit;
  if (featureLower.contains('tv')) return Icons.tv;
  if (featureLower.contains('kitchen')) return Icons.kitchen;
  if (featureLower.contains('free mattress')) return Icons.hotel;
  if (featureLower.contains('study area')) return Icons.menu_book;

  return Icons.wifi; // default icon
}
