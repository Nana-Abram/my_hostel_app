import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';

class BookingCard extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback? onStatusUpdated;

  const BookingCard({super.key, required this.booking, this.onStatusUpdated});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _isUpdating = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'checked-in':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'checked-in':
        return 'Checked In';
      default:
        return status;
    }
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    try {
      final bookingService = BookingService();
      await bookingService.updateBookingStatus(widget.booking.id, newStatus);

      if (widget.onStatusUpdated != null) {
        widget.onStatusUpdated!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking ${newStatus}d successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Booking'),
        content: Text('Are you sure you want to confirm this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateBookingStatus('confirmed');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Booking'),
        content: Text('Are you sure you want to reject this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateBookingStatus('cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _buildBookingDetailsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showBookingDetails,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      widget.booking.status,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _getStatusText(widget.booking.status),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(widget.booking.status),
                    ),
                  ),
                ),

                // Booking ID
                Text(
                  '#${widget.booking.id.substring(0, 8)}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Hostel Info
            Text(
              widget.booking.hostelName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 8.h),

            // Customer Info
            Row(
              children: [
                Icon(Icons.person_outline, size: 16.w, color: Colors.blueGrey),
                SizedBox(width: 6.w),
                Text(
                  widget.booking.userName,
                  style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Room Info
            Row(
              children: [
                Icon(
                  Icons.king_bed_outlined,
                  size: 16.w,
                  color: Colors.blueGrey,
                ),
                SizedBox(width: 6.w),
                Text(
                  widget.booking.roomType,
                  style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Bottom Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
                    ),
                    Text(
                      'GHS ${widget.booking.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueColor,
                      ),
                    ),
                  ],
                ),

                // Dates
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Check-in',
                      style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
                    ),
                    Text(
                      _formatDate(widget.booking.checkInDate),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Action Buttons (only for pending bookings)
            if (widget.booking.isPending && !_isUpdating) ...[
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Confirm'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showRejectDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Reject'),
                    ),
                  ),
                ],
              ),
            ] else if (_isUpdating) ...[
              SizedBox(height: 16.h),
              Center(
                child: CircularProgressIndicator(color: AppColors.blueColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsSheet() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Booking Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      widget.booking.status,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _getStatusText(widget.booking.status),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(widget.booking.status),
                    ),
                  ),
                ),
                Text(
                  '#${widget.booking.id.substring(0, 8)}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Hostel Info
            Text(
              widget.booking.hostelName,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 8.h),

            Divider(),
            SizedBox(height: 16.h),

            // Customer Section
            Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12.h),

            _buildDetailRow(
              Icons.person_outline,
              'Name',
              widget.booking.userName,
            ),
            _buildDetailRow(
              Icons.email_outlined,
              'Email',
              widget.booking.userEmail,
            ),
            _buildDetailRow(
              Icons.phone_outlined,
              'Phone',
              widget.booking.userPhone,
            ),

            SizedBox(height: 20.h),

            // Booking Details
            Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12.h),

            _buildDetailRow(
              Icons.king_bed_outlined,
              'Room Type',
              widget.booking.roomType,
            ),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Check-in Date',
              _formatDate(widget.booking.checkInDate),
            ),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Booked On',
              _formatDate(widget.booking.createdAt),
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                Icon(
                  Icons.attach_money_outlined,
                  size: 20.w,
                  color: Colors.blueGrey,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Text(
                        'GHS ${widget.booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Special Requests
            if (widget.booking.specialRequests != null &&
                widget.booking.specialRequests!.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Text(
                'Special Requests',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.booking.specialRequests!,
                style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
              ),
            ],

            SizedBox(height: 10.h),
            Text(
              'Payment Screenshot',
              style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
            ),
            ImageNetwork(
              image: widget.booking.confirmationImage,
              height: 150.h,
              width: 0.4.sw,
              fitWeb: BoxFitWeb.cover,
              fitAndroidIos: BoxFit.cover,
              borderRadius: BorderRadius.circular(8.r),
            ),
            SizedBox(height: 30.h),

            // Action Buttons for pending bookings
            if (widget.booking.isPending && !_isUpdating) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text('Confirm Booking'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showRejectDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text('Reject Booking'),
                    ),
                  ),
                ],
              ),
            ] else if (_isUpdating) ...[
              Center(
                child: CircularProgressIndicator(color: AppColors.blueColor),
              ),
            ],

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: Colors.blueGrey),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
