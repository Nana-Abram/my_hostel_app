import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/booking_card.dart';

class OwnerBookingsPage extends ConsumerStatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  ConsumerState<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends ConsumerState<OwnerBookingsPage> {
  String _selectedFilter = 'all';
  String _selectedSort = 'newest';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final theme = Theme.of(context);

    if (user == null) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          _buildFilterSortRow(theme),
          Expanded(child: _buildBookingsList(user, theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          // Tooltip(
          //   message: 'Back',
          //   child: IconAndTextWidget(
          //       icon: Icons.arrow_back_ios,
          //       iconColor: theme.colorScheme.onSurfaceVariant,
          //       isBackArrow: true,
                
          //     ),
          // ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bookings',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Manage bookings for your hostels',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortRow(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownContainer(
              theme: theme,
              child: DropdownButton<String>(
                value: _selectedFilter,
                isExpanded: true,
                icon: Icon(Icons.filter_list, size: 20.w, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                dropdownColor: theme.colorScheme.surface,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14.sp),
                items: [
                  _buildDropdownItem('all', 'All Bookings', theme),
                  _buildDropdownItem('pending', 'Pending', theme),
                  _buildDropdownItem('confirmed', 'Confirmed', theme),
                  _buildDropdownItem('checked-in', 'Checked In', theme),
                  _buildDropdownItem('cancelled', 'Cancelled', theme),
                ],
                onChanged: (value) => setState(() => _selectedFilter = value!),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 140.w,
            child: _buildDropdownContainer(
              theme: theme,
              child: DropdownButton<String>(
                value: _selectedSort,
                isExpanded: true,
                icon: Icon(Icons.sort, size: 20.w, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                dropdownColor: theme.colorScheme.surface,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14.sp),
                items: [
                  _buildDropdownItem('newest', 'Newest First', theme),
                  _buildDropdownItem('oldest', 'Oldest First', theme),
                  _buildDropdownItem('checkin', 'Check-in Date', theme),
                ],
                onChanged: (value) => setState(() => _selectedSort = value!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer({required ThemeData theme, required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String text, ThemeData theme) {
    return DropdownMenuItem(
      value: value,
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildBookingsList(UserModel user, ThemeData theme) {
    final bookingService = BookingService();

    return StreamBuilder<List<BookingModel>>(
      stream: bookingService.getBookingsByOwner(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.w, color: theme.colorScheme.error),
                SizedBox(height: 16.h),
                Text(
                  'Error loading bookings',
                  style: TextStyle(fontSize: 16.sp, color: theme.colorScheme.error),
                ),
              ],
            ),
          );
        }

        final allBookings = snapshot.data ?? [];

        List<BookingModel> filteredBookings = _selectedFilter == 'all'
            ? allBookings
            : allBookings.where((b) => b.status == _selectedFilter).toList();

        filteredBookings = _sortBookings(filteredBookings, _selectedSort);

        if (filteredBookings.isEmpty) {
          return _buildEmptyState(theme);
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: theme.colorScheme.primary,
          child: ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: filteredBookings.length,
            separatorBuilder: (_, __) => SizedBox(height: 16.h),
            itemBuilder: (_, index) => BookingCard(
              booking: filteredBookings[index],
              onStatusUpdated: () => setState(() {}),
            ),
          ),
        );
      },
    );
  }

  List<BookingModel> _sortBookings(List<BookingModel> bookings, String sortBy) {
    final sorted = List<BookingModel>.from(bookings);
    switch (sortBy) {
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'oldest':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case 'checkin':
        sorted.sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
    }
    return sorted;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80.w,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 20.h),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _selectedFilter == 'all'
                ? "You don't have any bookings yet"
                : 'No $_selectedFilter bookings',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
