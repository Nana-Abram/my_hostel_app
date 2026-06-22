import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/ui/booking/widgets/booking_appbar.dart';
import 'package:my_hostel_app/ui/hostels/available_rooms.dart';
import 'package:my_hostel_app/ui/hostels/booking_card.dart';
import 'package:my_hostel_app/ui/hostels/image_slider_h_d.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';
import 'package:my_hostel_app/ui/widgets/hostel_map_widget.dart';

class HostelDetailsPage extends ConsumerWidget {
  const HostelDetailsPage({super.key, required this.hostelId});

  final String hostelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch hostel data using the ID
    final theme = Theme.of(context);
    final hostelAsync = ref.watch(hostelByIdProvider(hostelId));
    final roomsAsync = ref.watch(roomsByHostelProvider(hostelId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const BookingAppBar(),
      body: hostelAsync.when(
        loading: () {
          final isMobileLoad = MediaQuery.sizeOf(context).width < 600;
          return SingleChildScrollView(
            padding: isMobileLoad ? const EdgeInsets.all(16) : EdgeInsets.all(40.w),
            child: Column(
              children: [
                SkeletonCard(height: isMobileLoad ? 220 : 400),
                SizedBox(height: 24.h),
                if (isMobileLoad) ...[
                  const SkeletonCard(height: 180),
                  SizedBox(height: 16.h),
                  const SkeletonCard(height: 180),
                  SizedBox(height: 16.h),
                  const SkeletonCard(height: 250),
                ] else
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const SkeletonCard(height: 200),
                            SizedBox(height: 16.h),
                            const SkeletonCard(height: 200),
                          ],
                        ),
                      ),
                      SizedBox(width: 24.w),
                      const Expanded(
                        child: SkeletonCard(height: 300),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => NetworkErrorState(
          onRetry: () {
            // Trigger a rebuild by invalidating the provider
          },
        ),
        data: (hostel) {
          if (hostel == null) {
            return NotFoundErrorState(
              resourceName: 'Hostel',
              onGoBack: () {
                GoRouter.of(context).go('/');
              },
            );
          }

          return _buildHostelContent(context, hostel, roomsAsync);
        },
      ),
    );
  }

  Widget _buildHostelContent(BuildContext context, HostelModel hostel, AsyncValue<List<dynamic>> roomsAsync) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return Container(
      margin: isMobile
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          : EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            IconAndTextWidget(
              icon: Icons.arrow_back_ios,
              text: 'Back to search',
              iconColor: theme.colorScheme.onSurfaceVariant,
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
                  return _buildMobileLayout(hostel, roomsAsync, theme);
                } else {
                  return _buildDesktopLayout(hostel, roomsAsync, theme);
                }
              },
            ),

            // Location map
            SizedBox(height: 30.h),
            _buildLocationMap(hostel, theme),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(HostelModel hostel, AsyncValue<List<dynamic>> roomsAsync, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Hostel details and rooms
        Expanded(
          flex: 2,
          child: _buildHostelDetailsAndRooms(hostel, roomsAsync, theme),
        ),
        
        SizedBox(width: 30.w),
        
        // Right column - Booking cards
        Expanded(
          flex: 1,
          child: BookingCardWidget(hostel: hostel),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(HostelModel hostel, AsyncValue<List<dynamic>> roomsAsync, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHostelDetailsAndRooms(hostel, roomsAsync, theme),
        SizedBox(height: 30.h),
        SizedBox(
          width: double.infinity,
          child: BookingCardWidget(hostel: hostel),
        ),
      ],
    );
  }

  Widget _buildHostelDetailsAndRooms(HostelModel hostel, AsyncValue<List<dynamic>> roomsAsync, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hostel name and rating
        SmallText(text: hostel.name, color: theme.colorScheme.onSurface, size: 16.sp),
        SizedBox(height: 15.h),
        
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconAndTextWidget(
              icon: Icons.star,
              text: hostel.rating.toStringAsFixed(1),
              iconColor: theme.colorScheme.tertiary,
              textColor: theme.colorScheme.onSurface,
            ),
            SmallText(text: "(${hostel.reviewsCount} reviews)"),
            IconAndTextWidget(
              icon: Icons.location_on_outlined,
              text: hostel.campus,
              iconColor: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        SizedBox(height: 30.h),

        // About section
        _buildAboutSection(hostel, theme),
        SizedBox(height: 20.h),

        // Video tour section (if available)
        if (hostel.videoTourUrl != null && hostel.videoTourUrl!.isNotEmpty) ...[
          _buildVideoTourSection(hostel, theme),
          SizedBox(height: 30.h),
        ],

        // Amenities
        _buildAmenitiesSection(hostel, theme),
        SizedBox(height: 30.h),

        // Available rooms
        SmallText(text: "Available Rooms", color: theme.colorScheme.onSurface, size: 16.sp),
        SizedBox(height: 20.h),
        
        // Rooms list with proper loading/error states
        roomsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40.sp),
                SizedBox(height: 10.h),
                SmallText(
                  text: "Failed to load rooms",
                  color: theme.colorScheme.error,
                  size: 12.sp,
                ),
              ],
            ),
          ),
          data: (rooms) {
            if (rooms.isEmpty) {
              return _buildNoRoomsAvailable(theme);
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

  Widget _buildAboutSection(HostelModel hostel, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor,
          width: 0.5.w,
        ),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
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
            color: theme.colorScheme.onSurface,
            size: 16.sp,
          ),
          SizedBox(height: 12.h),
          SmallText(
            text: hostel.description,
            size: 12.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTourSection(HostelModel hostel, ThemeData theme) {
    return VideoTourCard(
      videoUrl: hostel.videoTourUrl!,
      title: 'Virtual Tour',
      description: 'Take a virtual tour of ${hostel.name} to explore the facilities and rooms.',
    );
  }

  Widget _buildAmenitiesSection(HostelModel hostel, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor,
          width: 0.5.w,
        ),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
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
            color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getAmenityIcon(amenity),
                      size: 16.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      amenity,
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
        ],
      ),
    );
  }

  Widget _buildNoRoomsAvailable(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.hotel, size: 50.sp, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(height: 15.h),
          BigText(
            text: "No rooms available",
            color: theme.colorScheme.onSurfaceVariant,
            size: 16.sp,
          ),
          SizedBox(height: 10.h),
          SmallText(
            text: "Check back later for new room listings",
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMap(HostelModel hostel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallText(text: "Location", color: theme.colorScheme.onSurface, size: 16.sp),
        SizedBox(height: 16.h),
        HostelMapWidget(hostel: hostel),
      ],
    );
  }
}

// Helper functions remain the same
class RowIconAndText extends StatelessWidget {
  const RowIconAndText({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
          child: Icon(icon, size: 22.sp, color: theme.colorScheme.primary),
        ),
        SizedBox(width: 10.w),
        SmallText(text: text, color: theme.colorScheme.onSurface),
      ],
    );
  }
}

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