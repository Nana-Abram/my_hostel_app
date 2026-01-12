import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/provider/booking_provider.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

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
              loading: () => ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: const SkeletonCard(height: 150),
                ),
              ),
              error: (error, stack) => NetworkErrorState(
                onRetry: () {
                  ref.invalidate(userBookingsProvider(currentUser.id));
                },
              ),
              data: (bookings) {
                final filteredBookings = _filterBookings(bookings, _selectedFilter);
                return PullToRefreshWrapper(
                  onRefresh: () async {
                    ref.invalidate(userBookingsProvider(currentUser.id));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: _buildBookingsList(context, filteredBookings),
                );
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

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
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
                  HapticUtils.selectionClick();
                  setState(() {
                    _selectedFilter = filter['value']!;
                  });
                },
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  fontSize: 12.sp,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings, String filter) {
    if (filter == 'all') return bookings;
    return bookings.where((booking) => booking.status == filter).toList();
  }

  Widget _buildBookingsList(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return EmptyBookingsState(
        onBrowse: () {
          context.go('/hostels');
        },
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
    final theme = Theme.of(context);
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
                    color: theme.colorScheme.onSurface,
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
            SmallText(text: booking.roomType, color: theme.colorScheme.onSurfaceVariant),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14.sp, color: theme.colorScheme.onSurfaceVariant),
                SizedBox(width: 4.w),
                SmallText(
                  text: 'Check-in: ${_formatDate(booking.checkInDate)}',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 11.sp,
                ),
                SizedBox(width: 16.w),
                Icon(Icons.attach_money, size: 14.sp, color: theme.colorScheme.onSurfaceVariant),
                SizedBox(width: 4.w),
                SmallText(
                  text: 'GHS ${booking.totalPrice.toStringAsFixed(2)}',
                  color: theme.colorScheme.onSurfaceVariant,
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
        return const Color(0xFFFF9800); // orange
      case 'confirmed':
        return const Color(0xFF4CAF50); // green
      case 'cancelled':
        return const Color(0xFFF44336); // red
      default:
        return const Color(0xFF9E9E9E); // grey
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