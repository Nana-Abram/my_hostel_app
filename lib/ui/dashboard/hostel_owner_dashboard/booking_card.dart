import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/widgets/modern/image_widgets.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';

class BookingCard extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback? onStatusUpdated;

  const BookingCard({super.key, required this.booking, this.onStatusUpdated});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _isUpdating = false;

  // ── Status helpers ────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'checked-in':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'checked-in':
        return 'Checked In';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // ── Status update ─────────────────────────────────────────────────────────

  Future<void> _updateBookingStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final theme = Theme.of(context);

    try {
      await BookingService().updateBookingStatus(widget.booking.id, newStatus);
      widget.onStatusUpdated?.call();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking $newStatus successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: const Text('Are you sure you want to confirm this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateBookingStatus('confirmed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Booking'),
        content: const Text('Are you sure you want to reject this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateBookingStatus('cancelled');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Check In Guest'),
        content: const Text('Mark this booking as checked in?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateBookingStatus('checked-in');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _buildBookingDetailsSheet(theme),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.booking.status;
    final statusColor = _statusColor(status);

    return GestureDetector(
      onTap: _showBookingDetails,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge + booking ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(statusColor, status, fontSize: 12.sp),
                Text(
                  '#${widget.booking.id.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Hostel name
            Text(
              widget.booking.hostelName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 8.h),

            // Customer
            _buildIconRow(Icons.person_outline, widget.booking.userName, theme),
            SizedBox(height: 4.h),

            // Room type
            _buildIconRow(Icons.king_bed_outlined, widget.booking.roomType, theme),

            SizedBox(height: 16.h),

            // Price + check-in date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      'GHS ${widget.booking.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Check-in',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      _formatDate(widget.booking.checkInDate),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Action buttons
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet ──────────────────────────────────────────────────────────

  Widget _buildBookingDetailsSheet(ThemeData theme) {
    final status = widget.booking.status;
    final statusColor = _statusColor(status);

    return Container(
      padding: EdgeInsets.all(24.w),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 60.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Status badge + booking ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(statusColor, status, fontSize: 14.sp),
                Text(
                  '#${widget.booking.id.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Hostel name
            Text(
              widget.booking.hostelName,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 8.h),
            Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            SizedBox(height: 16.h),

            // Customer information
            _buildSectionTitle('Customer Information', theme),
            SizedBox(height: 12.h),
            _buildDetailRow(Icons.person_outline, 'Name', widget.booking.userName, theme),
            _buildDetailRow(Icons.email_outlined, 'Email', widget.booking.userEmail, theme),
            _buildDetailRow(Icons.phone_outlined, 'Phone', widget.booking.userPhone, theme),

            SizedBox(height: 20.h),

            // Booking details
            _buildSectionTitle('Booking Details', theme),
            SizedBox(height: 12.h),
            _buildDetailRow(Icons.king_bed_outlined, 'Room Type', widget.booking.roomType, theme),
            _buildDetailRow(Icons.calendar_today_outlined, 'Check-in Date', _formatDate(widget.booking.checkInDate), theme),
            _buildDetailRow(Icons.calendar_today_outlined, 'Booked On', _formatDate(widget.booking.createdAt), theme),

            SizedBox(height: 8.h),

            // Total price row
            Row(
              children: [
                Icon(Icons.attach_money_outlined, size: 20.w,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        'GHS ${widget.booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Special requests
            if (widget.booking.specialRequests != null &&
                widget.booking.specialRequests!.isNotEmpty) ...[
              SizedBox(height: 20.h),
              _buildSectionTitle('Special Requests', theme),
              SizedBox(height: 8.h),
              Text(
                widget.booking.specialRequests!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],

            SizedBox(height: 20.h),

            // Payment screenshot
            _buildSectionTitle('Payment Screenshot', theme),
            SizedBox(height: 8.h),
            _buildPaymentScreenshot(theme),

            SizedBox(height: 24.h),

            // Action buttons (detail sheet)
            _buildActionButtons(theme, isSheet: true),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // ── Shared sub-widgets ────────────────────────────────────────────────────

  Widget _buildStatusBadge(Color color, String status, {required double fontSize}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        _statusText(status),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentScreenshot(ThemeData theme) {
    final imageUrl = widget.booking.confirmationImage;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 28.w, color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
              SizedBox(height: 6.h),
              Text(
                'No screenshot provided',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => EnhancedCachedImage(
        imageUrl: imageUrl,
        height: 150.h,
        width: constraints.maxWidth,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8.r),
        placeholder: Container(
          height: 150.h,
          color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.4),
          child: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
        ),
        errorWidget: Container(
          height: 150.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(Icons.broken_image_outlined,
                size: 32.w, color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, {bool isSheet = false}) {
    final padding = isSheet ? EdgeInsets.symmetric(vertical: 16.h) : EdgeInsets.zero;

    if (_isUpdating) {
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    if (widget.booking.isPending) {
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _showConfirmDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(isSheet ? 'Confirm Booking' : 'Confirm'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton(
                onPressed: _showRejectDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(isSheet ? 'Reject Booking' : 'Reject'),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.booking.status == 'confirmed') {
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showCheckInDialog,
            icon: const Icon(Icons.key, size: 18),
            label: const Text('Mark as Checked In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
