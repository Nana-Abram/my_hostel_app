import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/provider/booking_provider.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: const Center(child: Text('Please log in to view bookings')),
      );
    }

    final bookingsAsync = ref.watch(userBookingsProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          
          // Bookings list
          Expanded(
            child: bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (bookings) {
                final filteredBookings = _filterBookings(bookings, _selectedFilter);
                return _buildBookingsList(context, filteredBookings);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'value': 'all', 'label': 'All'},
      {'value': 'pending', 'label': 'Pending'},
      {'value': 'confirmed', 'label': 'Confirmed'},
      {'value': 'cancelled', 'label': 'Cancelled'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      child: Wrap(
        spacing: 8.w,
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['value'];
          return ChoiceChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter['value']!;
              });
            },
            selectedColor: Colors.blue,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 12.sp,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings, String filter) {
    if (filter == 'all') return bookings;
    return bookings.where((booking) => booking.status == filter).toList();
  }

  Widget _buildBookingsList(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 60.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No bookings found',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(context, booking);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BigText(
                    text: booking.hostelName,
                    color: Colors.black,
                    size: 16.sp,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
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
            SmallText(text: booking.roomType, color: Colors.blueGrey),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: Colors.blueGrey),
                SizedBox(width: 4.w),
                SmallText(
                  text: 'Check-in: ${_formatDate(booking.checkInDate)}',
                  color: Colors.blueGrey,
                  size: 11.sp,
                ),
                SizedBox(width: 16.w),
                Icon(Icons.attach_money, size: 14.sp, color: Colors.blueGrey),
                SizedBox(width: 4.w),
                SmallText(
                  text: 'GHS ${booking.totalPrice.toStringAsFixed(2)}',
                  color: Colors.blueGrey,
                  size: 11.sp,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewBookingDetails(context, booking),
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: 8.w),
                if (booking.status == 'pending')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _cancelBooking(context, booking.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewBookingDetails(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Hostel', booking.hostelName),
              _buildDetailRow('Room Type', booking.roomType),
              _buildDetailRow('Check-in Date', _formatDate(booking.checkInDate)),
              _buildDetailRow('Status', booking.status),
              _buildDetailRow('Total Price', 'GHS ${booking.totalPrice.toStringAsFixed(2)}'),
              _buildDetailRow('Booking Date', _formatDate(booking.createdAt)),
              if (booking.specialRequests != null && booking.specialRequests!.isNotEmpty)
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
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel booking functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking cancellation feature coming soon')),
              );
            },
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}