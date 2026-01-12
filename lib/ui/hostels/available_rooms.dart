import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/ui/hostels/hostels_card.dart';
import 'package:my_hostel_app/ui/hostels/room_details_page.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

class AvailableRooms extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return HapticGestureDetector(
      onTap: () {
        // Navigate to room details page with animation
        navigateWithAnimation(
          context,
          RoomDetailsPage(room: room, hostel: hostel),
          transitionType: PageTransitionType.fadeAndSlide,
        );
      },
      feedbackType: HapticFeedbackType.light,
      child: Container(
        width: isHostelOwner ? 0.9.sw : 0.5.sw,
        height: isHostelOwner ? 300.h : 270.h,
        margin: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.dividerColor, width: 0.5.w),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
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
              child: Hero(
                tag: 'room-${room.id}',
                child: ImageNetwork(
                  image: room.image,
                  height: 355.h,
                  width: isHostelOwner ? 440.w : 250.w,
                  fitAndroidIos: BoxFit.cover,
                  fitWeb: BoxFitWeb.cover,
                  onTap: () {
                    // Navigate to room details page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RoomDetailsPage(
                          room: room,
                          hostel: hostel,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            /// ROOM DETAILS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// TITLE + PRICE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmallText(
                          text: room.type,
                          color: theme.colorScheme.onSurface,
                          size: 13.sp,
                        ),
                        SmallText(
                          text: room.capacity == 1
                              ? "GHS${room.price.toStringAsFixed(2)}"
                              : "Per head: GHS${(room.price).toStringAsFixed(2)}",
                          color: theme.colorScheme.primary,
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
                          iconColor: theme.colorScheme.onSurfaceVariant,
                          textSize: 12.sp,
                        ),
                        SmallText(
                          text: "Per Year",
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 12.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),

                    /// ROOM FEATURES
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      alignment: WrapAlignment.start,
                      children: room.features.map((feature) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getFeatureIcon(feature),
                                size: 16.sp,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: theme.colorScheme.primary,
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
                          ? theme.colorScheme.secondary.withOpacity(0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      text: room.available ? "Available" : "Unavailable",
                      textColor: room.available
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface,
                      textSize: 12.sp,
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmallText(
                          text: "Gender: ${room.gender}",
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 12.sp,
                        ),
                        isHostelOwner
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RoomDetailsPage(
                                        room: room,
                                        hostel: hostel,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 16.sp,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                      SizedBox(width: 6.w),
                                      SmallText(
                                        text: "View Details",
                                        color: theme.colorScheme.onPrimary,
                                        size: 13.sp,
                                      ),
                                    ],
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
