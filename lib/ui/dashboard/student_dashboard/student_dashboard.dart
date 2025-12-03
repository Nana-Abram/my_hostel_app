import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/model/dashboard_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/provider/dashboard_provider.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view dashboard'));
    }

    final dashboardAsync = ref.watch(studentDashboardProvider(currentUser.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dashboard Header
            _buildDashboardHeader(context, currentUser),

            // Dashboard Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
              child: dashboardAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50.sp),
                      SizedBox(height: 16.h),
                      Text('Error loading dashboard'),
                    ],
                  ),
                ),
                data: (dashboardData) =>
                    _buildDashboardContent(context, dashboardData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context, UserModel user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Tooltip(
                  message: 'Back to home',
                  child: const IconAndTextWidget(
                    icon: Icons.arrow_back_ios,
                    text: '',
                    iconColor: Colors.blueGrey,
                    isBackArrow: true,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BigText(
                      text: "My Dashboard",
                      color: Colors.black,
                      size: 24.sp,
                    ),
                    SizedBox(height: 4.h),
                    SmallText(
                      text: "Welcome back, ${user.fullName}",
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              ],
            ),
          ),

          ElvButtonWidget(
            text: "Book New Hostel",
            isPrimary: true,
            onPressed: () {
              GoRouter.of(context).goNamed('home');
            }, // Navigate to hostels tab
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    StudentDashboardData data,
  ) {
    return Column(
      children: [
        // Statistics Cards
        _buildStatisticsSection(data),
        SizedBox(height: 30.h),

        // Recent Bookings
        _buildRecentBookingsSection(context, data),
        SizedBox(height: 30.h),

        // Upcoming Bookings
        _buildUpcomingBookingsSection(context, data),
      ],
    );
  }

  Widget _buildStatisticsSection(StudentDashboardData data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 20.w,
      mainAxisSpacing: 20.h,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.bookmark,
          title: 'Total Bookings',
          value: data.totalBookings.toString(),
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.pending_actions,
          title: 'Pending',
          value: data.pendingBookings.toString(),
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.check_circle,
          title: 'Confirmed',
          value: data.confirmedBookings.toString(),
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.attach_money,
          title: 'Total Spent',
          value: 'GHS ${data.totalSpent.toStringAsFixed(2)}',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          BigText(text: value, color: Colors.black, size: 20.sp),
          SizedBox(height: 4.h),
          SmallText(text: title, color: Colors.blueGrey, size: 11.sp),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsSection(
    BuildContext context,
    StudentDashboardData data,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BigText(
                text: "Recent Bookings",
                color: Colors.black,
                size: 18.sp,
              ),
              if (data.recentBookings.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/my-bookings'),
                  child: Text(
                    'View All',
                    style: TextStyle(color: Colors.blue, fontSize: 12.sp),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          if (data.recentBookings.isEmpty)
            _buildEmptyState(
              icon: Icons.bookmark_border,
              title: 'No Recent Bookings',
              subtitle: 'You haven\'t made any bookings yet',
              buttonText: 'Browse Hostels',
              onPressed: () => context.go('home'),
            )
          else
            Column(
              children: data.recentBookings
                  .map((booking) => _buildBookingItem(context, booking))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingBookingsSection(
    BuildContext context,
    StudentDashboardData data,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BigText(text: "Upcoming Stays", color: Colors.black, size: 18.sp),
              if (data.upcomingBookings.isNotEmpty)
                TextButton(
                  onPressed: () => context.push('/my-bookings'),
                  child: Text(
                    'View All',
                    style: TextStyle(color: Colors.blue, fontSize: 12.sp),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          if (data.upcomingBookings.isEmpty)
            _buildEmptyState(
              icon: Icons.calendar_today,
              title: 'No Upcoming Stays',
              subtitle: 'You don\'t have any confirmed bookings',
              buttonText: 'Check Bookings',
              onPressed: () => context.push('/my-bookings'),
            )
          else
            Column(
              children: data.upcomingBookings
                  .map((booking) => _buildBookingItem(context, booking))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, BookingModel booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 8.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 16.w),

          // Booking details
          Expanded(
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
                        size: 14.sp,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
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
                SizedBox(height: 4.h),
                SmallText(
                  text: booking.roomType,
                  color: Colors.blueGrey,
                  size: 11.sp,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    IconAndTextWidget(
                      icon: Icons.calendar_today,
                      text: _formatDate(booking.checkInDate),
                      iconColor: Colors.blueGrey,
                      textSize: 10.sp,
                    ),
                    SizedBox(width: 16.w),
                    IconAndTextWidget(
                      icon: Icons.attach_money,
                      text: 'GHS ${booking.totalPrice.toStringAsFixed(2)}',
                      iconColor: Colors.blueGrey,
                      textSize: 10.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View button
          SizedBox(width: 12.w),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 20.sp),
            onPressed: () => _viewBookingDetails(context, booking),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(icon, size: 60.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewBookingDetails(BuildContext context, BookingModel booking) {
    // Navigate to booking details page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hostel: ${booking.hostelName}'),
            Text('Room: ${booking.roomType}'),
            Text('Check-in: ${_formatDate(booking.checkInDate)}'),
            Text('Status: ${booking.status}'),
            Text('Amount: GHS ${booking.totalPrice.toStringAsFixed(2)}'),
            if (booking.specialRequests != null &&
                booking.specialRequests!.isNotEmpty)
              Text('Special Requests: ${booking.specialRequests}'),
          ],
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
}
