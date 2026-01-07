import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';

class DashboardPage extends ConsumerWidget {
  final Function(int) onIndexChanged;
  const DashboardPage({super.key, required this.onIndexChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUserId = authState.value?.id;
    
    if (currentUserId == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    final hostelsAsync = ref.watch(hostelsByOwnerProvider(currentUserId));
    final bookingService = BookingService();
    
    return Scaffold(
     body: LayoutBuilder(
  builder: (context, constraints) {
    // final isSmall = constraints.maxWidth < 600; 

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconAndTextWidget(
              icon: Icons.arrow_back_ios,
              text: 'Back to home',
              iconColor: Colors.blueGrey,
              isBackArrow: true,
            ),
            SizedBox(height: 20.h),

            _buildWelcomeSection(ref),
            SizedBox(height: 24.h),

            // QUICK STATS + RECENT ACTIVITY
            StreamBuilder<List<dynamic>>(
              stream: _getDashboardStatsStream(
                currentUserId,
                bookingService,
                hostelsAsync,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data!;
                final totalHostels = stats[0];
                final activeBookings = stats[1];
                final pendingRequests = stats[2];
                final totalEarnings = stats[3];

                return Column(
                  children: [
                    _buildQuickStats(
                      // isSmall: isSmall,
                      totalHostels: totalHostels,
                      activeBookings: activeBookings,
                      pendingRequests: pendingRequests,
                      totalEarnings: totalEarnings,
                    ),
                    SizedBox(height: 24.h),

                    SizedBox(
                      height: 500.h, // Ensures list displays fully
                      child: _buildRecentActivity(
                        currentUserId,
                        bookingService,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  },
),

    
    );
  }

  Stream<List<dynamic>> _getDashboardStatsStream(
    String ownerId, 
    BookingService bookingService,
    AsyncValue<List<dynamic>> hostelsAsync
  ) async* {
    // Get total hostels count
    int totalHostels = 0;
    if (hostelsAsync.value != null) {
      totalHostels = hostelsAsync.value!.length;
    }
    
    // Get booking stats
    try {
      final bookings = await bookingService.getBookingsByOwnerOnce(ownerId);
      
      final activeBookings = bookings
          .where((b) => b.status == 'confirmed' || b.status == 'checked-in')
          .length;
      
      final pendingRequests = bookings
          .where((b) => b.status == 'pending')
          .length;
      
      final totalEarnings = bookings
          .where((b) => b.status == 'confirmed' || b.status == 'checked-in')
          .fold(0.0, (sum, booking) => sum + booking.totalPrice);
      
      yield [totalHostels, activeBookings, pendingRequests, totalEarnings];
    } catch (e) {
      print('Error getting booking stats: $e');
      yield [totalHostels, 0, 0, 0.0];
    }
  }

  Widget _buildWelcomeSection(WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final userName = user?.fullName.split(' ').first ?? 'Hostel Owner';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.w,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.business, color: Colors.blue[700], size: 30.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $userName!',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Manage your hostels and track performance',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildQuickStats({
  required int totalHostels,
  required int activeBookings,
  required int pendingRequests,
  required double totalEarnings,
}) {
  return Wrap(
    spacing: 16.w,          // horizontal spacing
    runSpacing: 16.h,       // vertical spacing
    children: [
      SizedBox(
        width: 0.48.sw,     // controls width of each item (ScreenUtil)
        child: _buildStatCard(
          title: 'Total Hostels',
          value: totalHostels.toString(),
          icon: Icons.business,
          color: Colors.blue,
          isLoading: totalHostels == 0,
        ),
      ),
      SizedBox(
        width: 0.48.sw,
        child: _buildStatCard(
          title: 'Active Bookings',
          value: activeBookings.toString(),
          icon: Icons.calendar_today,
          color: Colors.green,
          isLoading: activeBookings == 0 && pendingRequests == 0,
        ),
      ),
      SizedBox(
        width: 0.48.sw,
        child: _buildStatCard(
          title: 'Pending Requests',
          value: pendingRequests.toString(),
          icon: Icons.pending_actions,
          color: Colors.orange,
          isLoading: pendingRequests == 0 && activeBookings == 0,
        ),
      ),
      SizedBox(
        width: 0.48.sw,
        child: _buildStatCard(
          title: 'Total Earnings',
          value: 'GHS ${totalEarnings.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.purple,
          isLoading: totalEarnings == 0,
        ),
      ),
    ],
  );
}

Widget _buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  bool isLoading = false,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.5),
          color.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 2,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Card(
      color: Colors.white.withOpacity(0.85),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glow Icon Container
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 28.w,
              ),
            ),

            SizedBox(height: 12.h),

            // Value or Loader
            if (isLoading)
              SizedBox(
                height: 22.h,
                width: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

            SizedBox(height: 6.h),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildRecentActivity(String ownerId, BookingService bookingService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                onIndexChanged(2); // Navigate to bookings page
              },
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: StreamBuilder<List<dynamic>>(
            stream: _getRecentActivityStream(ownerId, bookingService),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error loading activity'));
              }
              
              final activities = snapshot.data ?? [];
              
              if (activities.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 64.w, color: Colors.grey[400]),
                      SizedBox(height: 16.h),
                      Text(
                        'No recent activity',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Activity will appear here',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return _buildActivityItem(
                    title: activity['title'],
                    time: activity['time'],
                    icon: activity['icon'],
                    color: activity['color'],
                    booking: activity['booking'],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<List<Map<String, dynamic>>> _getRecentActivityStream(
    String ownerId, 
    BookingService bookingService
  ) async* {
    try {
      final bookings = await bookingService.getBookingsByOwnerOnce(ownerId);
      
      // Sort by most recent
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Take only recent bookings (last 10)
      final recentBookings = bookings.take(10).toList();
      
      final activities = recentBookings.map((booking) {
        String title;
        IconData icon;
        Color color;
        
        switch (booking.status) {
          case 'pending':
            title = 'New booking request';
            icon = Icons.pending_actions;
            color = Colors.orange;
            break;
          case 'confirmed':
            title = 'Booking confirmed';
            icon = Icons.check_circle;
            color = Colors.green;
            break;
          case 'checked-in':
            title = 'Guest checked in';
            icon = Icons.key;
            color = Colors.blue;
            break;
          case 'cancelled':
            title = 'Booking cancelled';
            icon = Icons.cancel;
            color = Colors.red;
            break;
          default:
            title = 'Booking updated';
            icon = Icons.update;
            color = Colors.grey;
        }
        
        // Calculate time ago
        final now = DateTime.now();
        final difference = now.difference(booking.createdAt);
        String time;
        
        if (difference.inMinutes < 60) {
          time = '${difference.inMinutes} min ago';
        } else if (difference.inHours < 24) {
          time = '${difference.inHours} hours ago';
        } else if (difference.inDays < 7) {
          time = '${difference.inDays} days ago';
        } else {
          time = '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}';
        }
        
        return {
          'title': title,
          'time': time,
          'icon': icon,
          'color': color,
          'booking': booking,
        };
      }).toList();
      
      yield activities;
    } catch (e) {
      print('Error getting activity: $e');
      yield [];
    }
  }

  Widget _buildActivityItem({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
    BookingModel? booking,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 20.w),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp),
        ),
        subtitle: booking != null 
            ? Text(
                '${booking.userName} • ${booking.hostelName}',
                style: TextStyle(fontSize: 12.sp),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            if (booking != null && booking.totalPrice > 0)
              Text(
                'GHS ${booking.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
        onTap: booking != null ? () {
          // You could show booking details here
          print('Booking tapped: ${booking.id}');
        } : null,
      ),
    );
  }

}