import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/booking_card.dart';


class OwnerBookingsPage extends ConsumerStatefulWidget {
  const OwnerBookingsPage({super.key});

  @override
  ConsumerState<OwnerBookingsPage> createState() => _OwnerBookingsPageState();
}

class _OwnerBookingsPageState extends ConsumerState<OwnerBookingsPage> {
  String _selectedFilter = 'all'; // all, pending, confirmed, cancelled
  String _selectedSort = 'newest'; // newest, oldest, checkin

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          _buildHeader(user),
          
          // Filter and Sort Row
          _buildFilterSortRow(),
          
          // Bookings List
          Expanded(
            child: _buildBookingsList(user),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Manage bookings for your hostels',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        children: [
          // Filter Dropdown
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  icon: Icon(Icons.filter_list, size: 20.w),
                  items: [
                    _buildDropdownItem('all', 'All Bookings'),
                    _buildDropdownItem('pending', 'Pending'),
                    _buildDropdownItem('confirmed', 'Confirmed'),
                    _buildDropdownItem('cancelled', 'Cancelled'),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                  },
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Sort Dropdown
          Container(
            width: 140.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                isExpanded: true,
                icon: Icon(Icons.sort, size: 20.w),
                items: [
                  _buildDropdownItem('newest', 'Newest First'),
                  _buildDropdownItem('oldest', 'Oldest First'),
                  _buildDropdownItem('checkin', 'Check-in Date'),
                ],
                onChanged: (value) {
                  setState(() => _selectedSort = value!);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String text) {
    return DropdownMenuItem(
      value: value,
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildBookingsList(UserModel user) {
    final bookingService = BookingService();
    
    return StreamBuilder<List<BookingModel>>(
      stream: bookingService.getBookingsByOwner(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.blueColor));
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.w, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  'Error loading bookings',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                ),
              ],
            ),
          );
        }
        
        final allBookings = snapshot.data ?? [];
        
        // Apply filters
        List<BookingModel> filteredBookings = allBookings;
        
        if (_selectedFilter != 'all') {
          filteredBookings = allBookings
              .where((booking) => booking.status == _selectedFilter)
              .toList();
        }
        
        // Apply sorting
        filteredBookings = _sortBookings(filteredBookings, _selectedSort);
        
        if (filteredBookings.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            // Refresh logic if needed
          },
          child: ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: filteredBookings.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return BookingCard(
                booking: filteredBookings[index],
                onStatusUpdated: () {
                  // Refresh the list if needed
                  setState(() {});
                },
              );
            },
          ),
        );
      },
    );
  }

  List<BookingModel> _sortBookings(List<BookingModel> bookings, String sortBy) {
    List<BookingModel> sorted = List.from(bookings);
    
    switch (sortBy) {
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'checkin':
        sorted.sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
        break;
    }
    
    return sorted;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20.h),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _selectedFilter == 'all'
                ? 'You don\'t have any bookings yet'
                : 'No $_selectedFilter bookings',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}