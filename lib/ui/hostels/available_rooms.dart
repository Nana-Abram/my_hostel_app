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

  void _openRoomDetails(BuildContext context) {
    navigateWithAnimation(
      context,
      RoomDetailsPage(room: room, hostel: hostel),
      transitionType: PageTransitionType.fadeAndSlide,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return HapticGestureDetector(
      onTap: () => _openRoomDetails(context),
      feedbackType: HapticFeedbackType.light,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.dividerColor, width: 0.5.w),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: isMobile
            ? _buildMobileLayout(context, theme)
            : _buildDesktopLayout(context, theme),
      ),
    );
  }

  // ── Mobile: image on top, content below ─────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full-width image header
        LayoutBuilder(
          builder: (context, constraints) => ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            child: Hero(
              tag: 'room-${room.id}',
              child: ImageNetwork(
                image: room.image,
                height: 160,
                width: constraints.maxWidth,
                fitAndroidIos: BoxFit.cover,
                fitWeb: BoxFitWeb.cover,
                onTap: () => _openRoomDetails(context),
              ),
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room type + price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SmallText(
                      text: room.type,
                      color: theme.colorScheme.onSurface,
                      size: 13.sp,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SmallText(
                    text: room.capacity == 1
                        ? "GHS${room.price.toStringAsFixed(2)}"
                        : "GHS${room.price.toStringAsFixed(2)}/head",
                    color: theme.colorScheme.primary,
                    size: 13.sp,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Capacity + per year
              Row(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SmallText(
                      text: room.capacity == 1
                          ? "Capacity: ${room.capacity} student"
                          : "Capacity: ${room.capacity} students",
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 12.sp,
                    ),
                  ),
                  SmallText(
                    text: "Per Year",
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 12.sp,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Features
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: room.features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getFeatureIcon(feature),
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          feature,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Status badge + gender on one row
              Row(
                children: [
                  SmallContainerAndText(
                    containerColor: room.isFull
                        ? theme.colorScheme.error.withValues(alpha: 0.15)
                        : room.available
                            ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                            : theme.colorScheme.surfaceContainerHighest,
                    text: room.isFull
                        ? 'Fully Occupied'
                        : room.totalSpaces > 0
                            ? '${room.availableSpaces}/${room.totalSpaces} spaces'
                            : (room.available ? 'Available' : 'Unavailable'),
                    textColor: room.isFull
                        ? theme.colorScheme.error
                        : room.available
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface,
                    textSize: 11.sp,
                  ),
                  const SizedBox(width: 8),
                  SmallText(
                    text: "Gender: ${room.gender}",
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 11.sp,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // View Details — full width on mobile
              if (!isHostelOwner)
                GestureDetector(
                  onTap: () => _openRoomDetails(context),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, size: 16, color: theme.colorScheme.onPrimary),
                        const SizedBox(width: 6),
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
        ),
      ],
    );
  }

  // ── Desktop: image left, content right ──────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room image
        SizedBox(
          width: isHostelOwner ? 180.w : 150.w,
          height: isHostelOwner ? 220.h : 200.h,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            ),
            child: Hero(
              tag: 'room-${room.id}',
              child: ImageNetwork(
                image: room.image,
                height: isHostelOwner ? 220.h : 200.h,
                width: isHostelOwner ? 180.w : 150.w,
                fitAndroidIos: BoxFit.cover,
                fitWeb: BoxFitWeb.cover,
                onTap: () => _openRoomDetails(context),
              ),
            ),
          ),
        ),

        // Room details
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title + price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SmallText(
                        text: room.type,
                        color: theme.colorScheme.onSurface,
                        size: 13.sp,
                        overFlow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    SmallText(
                      text: room.capacity == 1
                          ? "GHS${room.price.toStringAsFixed(2)}"
                          : "Per head: GHS${room.price.toStringAsFixed(2)}",
                      color: theme.colorScheme.primary,
                      size: 13.sp,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Capacity + per year
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: IconAndTextWidget(
                        icon: Icons.people_alt_outlined,
                        text: room.capacity == 1
                            ? "Capacity: ${room.capacity} student"
                            : "Capacity: ${room.capacity} students",
                        iconColor: theme.colorScheme.onSurfaceVariant,
                        textSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    SmallText(
                      text: "Per Year",
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 12.sp,
                    ),
                  ],
                ),
                SizedBox(height: 15.h),

                // Features
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: room.features.map((feature) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getFeatureIcon(feature), size: 16.sp, color: theme.colorScheme.primary),
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

                // Status badge
                SmallContainerAndText(
                  containerColor: room.isFull
                      ? theme.colorScheme.error.withValues(alpha: 0.15)
                      : room.available
                          ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                  text: room.isFull
                      ? 'Fully Occupied'
                      : room.totalSpaces > 0
                          ? '${room.availableSpaces} of ${room.totalSpaces} spaces'
                          : (room.available ? 'Available' : 'Unavailable'),
                  textColor: room.isFull
                      ? theme.colorScheme.error
                      : room.available
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface,
                  textSize: 12.sp,
                ),
                SizedBox(height: 15.h),

                // Gender + view details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmallText(
                      text: "Gender: ${room.gender}",
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 12.sp,
                    ),
                    if (!isHostelOwner)
                      GestureDetector(
                        onTap: () => _openRoomDetails(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility, size: 16.sp, color: theme.colorScheme.onPrimary),
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
    );
  }
}

IconData _getFeatureIcon(String feature) {
  final f = feature.toLowerCase();
  if (f.contains('bed')) return Icons.bed;
  if (f.contains('desk')) return Icons.desk;
  if (f.contains('fan')) return Icons.ac_unit;
  if (f.contains('wardrobe')) return Icons.business;
  if (f.contains('air conditioning')) return Icons.ac_unit;
  if (f.contains('tv')) return Icons.tv;
  if (f.contains('kitchen')) return Icons.kitchen;
  if (f.contains('free mattress')) return Icons.hotel;
  if (f.contains('study area')) return Icons.menu_book;
  return Icons.wifi;
}
