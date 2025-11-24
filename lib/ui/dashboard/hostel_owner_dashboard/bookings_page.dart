// pages/hostel_owner/bookings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/provider/booking_provider.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statusTabs = ['All', 'Pending', 'Confirmed', ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return authState.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Bookings')),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text('Bookings')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (user) {
        if (user == null) {
          return _buildNotSignedInState();
        }
        
        return _buildBookingsPage(user.id);
      },
    );
  }

  Widget _buildBookingsPage(String ownerId) {
    final statsAsync = ref.watch(bookingStatsProvider(ownerId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _statusTabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Statistics Cards
          statsAsync.when(
            loading: () => Container(),
            error: (error, stack) => Container(),
            data: (stats) => _buildStatsCards(stats),
          ),
          
          // Bookings List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statusTabs.map((status) {
                return _buildBookingsList(ownerId, status);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, int> stats) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.grey[50],
      child: Row(
        children: [
          _buildStatCard('Total', stats['total'] ?? 0, Colors.blue),
          SizedBox(width: 8.w),
          _buildStatCard('Pending', stats['pending'] ?? 0, Colors.orange),
          SizedBox(width: 8.w),
          _buildStatCard('Confirmed', stats['confirmed'] ?? 0, Colors.green),
          SizedBox(width: 8.w),
          _buildStatCard('Today', stats['todayCheckIn'] ?? 0, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(String ownerId, String statusFilter) {
    final bookingsAsync = ref.watch(bookingsByOwnerProvider(ownerId));
    
    return bookingsAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (bookings) {
        // Filter bookings based on tab selection
        final filteredBookings = statusFilter == 'All' 
            ? bookings 
            : bookings.where((booking) {
                switch (statusFilter) {
                  case 'Pending': return booking.isPending;
                  case 'Confirmed': return booking.isConfirmed;
                  default: return true;
                }
              }).toList();

        if (filteredBookings.isEmpty) {
          return _buildEmptyState(statusFilter);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            return _buildBookingCard(filteredBookings[index]);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with booking ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id.substring(0, 8)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(booking.status)),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            // Hostel and Room info
            Text(
              booking.hostelName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Guest information
            _buildInfoRow('Guest', booking.userName),
            _buildInfoRow('Contact', '${booking.userPhone} • ${booking.userEmail}'),
            
            SizedBox(height: 8.h),
            
            // Dates and Price
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                      // Text(
                      //   // DateFormat('MMM dd, yyyy').format(booking.checkInDate),
                      //   style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-out',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                  
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                      Text(
                        '₹${booking.totalPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Action buttons based on status
            if (booking.isPending) _buildPendingActions(booking),
            if (booking.isConfirmed) _buildConfirmedActions(booking),
            
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(BookingModel booking) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _updateBookingStatus(booking.id, 'confirmed'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
            child: Text('Confirm'),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _updateBookingStatus(booking.id, 'cancelled'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Reject'),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedActions(BookingModel booking) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _updateBookingStatus(booking.id, 'checked-in'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
            child: Text('Check-in'),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showBookingDetails(booking),
            child: Text('View Details'),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckedInActions(BookingModel booking) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _updateBookingStatus(booking.id, 'checked-out'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.purple),
            child: Text('Check-out'),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showBookingDetails(booking),
            child: Text('View Details'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No $status Bookings',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'When you get $status.toLowerCase() bookings, they will appear here',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotSignedInState() {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'Please Sign In',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text('You need to be signed in to view bookings'),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'checked-in': return Colors.blue;
      case 'checked-out': return Colors.purple;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      final service = ref.read(bookingServiceProvider);
      await service.updateBookingStatus(bookingId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking status updated to $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking: $e')),
      );
    }
  }

  void _showBookingDetails(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Booking ID', booking.id),
              _buildDetailRow('Hostel', booking.hostelName),
              _buildDetailRow('Room Type', booking.roomType),
              _buildDetailRow('Guest', booking.userName),
              _buildDetailRow('Email', booking.userEmail),
              _buildDetailRow('Phone', booking.userPhone),
              // _buildDetailRow('Check-in', DateFormat('MMM dd, yyyy').format(booking.checkInDate)),
              _buildDetailRow('Total', '₹${booking.totalPrice}'),
              if (booking.specialRequests != null)
                _buildDetailRow('Special Requests', booking.specialRequests!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }
}