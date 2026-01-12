import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';

class RoomDetailsPage extends ConsumerStatefulWidget {
  const RoomDetailsPage({
    super.key,
    required this.room,
    required this.hostel,
  });

  final RoomModel room;
  final HostelModel hostel;

  @override
  ConsumerState<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends ConsumerState<RoomDetailsPage> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.room.images.isNotEmpty 
        ? widget.room.images 
        : [widget.room.image];
    
    // Debug: print the number of images
    debugPrint('Room ${widget.room.id} has ${images.length} image(s)');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 400.h,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image Gallery with PageView
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: index == 0 ? 'room-${widget.room.id}' : 'room-${widget.room.id}-$index',
                        child: ImageNetwork(
                          image: images[index],
                          height: 400.h,
                          width: 1.sw,
                          fitAndroidIos: BoxFit.cover,
                          fitWeb: BoxFitWeb.cover,
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Page indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 20.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            width: _currentImageIndex == index ? 24.w : 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Image counter badge
                  if (images.length > 1)
                    Positioned(
                      top: 60.h,
                      left: 20.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${_currentImageIndex + 1}/${images.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Availability badge
                  Positioned(
                    top: 60.h,
                    right: 20.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.room.available
                            ? const Color(0xFF4CAF50)
                            : theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.room.available ? Icons.check_circle : Icons.block,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            widget.room.available ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Thumbnail Gallery
                  if (images.length > 1)
                    Container(
                      margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Gallery',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 80.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                final isSelected = _currentImageIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    width: 80.w,
                                    margin: EdgeInsets.only(right: 12.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.dividerColor,
                                        width: isSelected ? 3 : 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: ImageNetwork(
                                        image: images[index],
                                        height: 80.h,
                                        width: 80.w,
                                        fitAndroidIos: BoxFit.cover,
                                        fitWeb: BoxFitWeb.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Room Info Card
                  Container(
                    margin: EdgeInsets.all(20.w),
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Type & Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.room.type,
                                    style: TextStyle(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    widget.hostel.name,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'GHS ${(widget.room.price).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    widget.room.capacity == 1 ? 'Total' : 'Per Person',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    'Per Year',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: theme.colorScheme.onPrimaryContainer
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),
                        Divider(color: theme.dividerColor),
                        SizedBox(height: 24.h),

                        // Quick Info Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                context,
                                icon: Icons.people,
                                label: 'Capacity',
                                value: '${widget.room.capacity} ${widget.room.capacity == 1 ? "Person" : "People"}',
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildInfoCard(
                                context,
                                icon: Icons.meeting_room,
                                label: 'Available Rooms',
                                value: '${widget.room.availableRooms} Rooms',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                context,
                                icon: widget.room.gender.toLowerCase() == 'male'
                                    ? Icons.male
                                    : widget.room.gender.toLowerCase() == 'female'
                                        ? Icons.female
                                        : Icons.people,
                                label: 'Gender',
                                value: widget.room.gender,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildInfoCard(
                                context,
                                icon: Icons.location_on,
                                label: 'Location',
                                value: widget.hostel.location,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Features Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room Features',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: widget.room.features.map((feature) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getFeatureIcon(feature),
                                    size: 20.sp,
                                    color: theme.colorScheme.primary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: theme.colorScheme.onSurface,
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

                  SizedBox(height: 24.h),

                  // Hostel Details Section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About ${widget.hostel.name}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          widget.hostel.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // _buildHostelInfo(
                        //   context,
                        //   icon: Icons.phone,
                        //   label: 'Contact',
                        //   value: ,
                        // ),
                        // SizedBox(height: 8.h),
                        // _buildHostelInfo(
                        //   context,
                        //   icon: Icons.email,
                        //   label: 'Email',
                        //   value: widget.hostel.email,
                        // ),
                      ],
                    ),
                  ),

                  SizedBox(height: 100.h), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),

      // Book Now Button (Fixed at bottom)
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: widget.room.available
                ? () => _handleBookNow(context, ref)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.room.available ? Icons.bookmark_add : Icons.block,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.room.available ? 'Book This Room' : 'Room Unavailable',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28.sp,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleBookNow(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final user = authState.value;

    if (user == null) {
      // Not logged in → redirect to login with return URL
      final bookingUrl = '/booking/${widget.hostel.id}/${widget.room.id}';
      final encodedUrl = Uri.encodeComponent(bookingUrl);

      context.push('/login?redirect=$encodedUrl');
      return;
    }

    // Logged in → go directly to booking page
    context.go('/booking/${widget.hostel.id}/${widget.room.id}');
  }

  IconData _getFeatureIcon(String feature) {
    final featureLower = feature.toLowerCase();

    if (featureLower.contains('bed')) return Icons.bed;
    if (featureLower.contains('desk')) return Icons.desk;
    if (featureLower.contains('fan')) return Icons.air;
    if (featureLower.contains('wardrobe')) return Icons.checkroom;
    if (featureLower.contains('air conditioning')) return Icons.ac_unit;
    if (featureLower.contains('tv')) return Icons.tv;
    if (featureLower.contains('kitchen')) return Icons.kitchen;
    if (featureLower.contains('mattress')) return Icons.hotel;
    if (featureLower.contains('study')) return Icons.menu_book;
    if (featureLower.contains('wifi')) return Icons.wifi;
    if (featureLower.contains('bathroom')) return Icons.bathroom;
    if (featureLower.contains('balcony')) return Icons.balcony;

    return Icons.check_circle; // default icon
  }
}

