import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/backend/service/room_service.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final Function(int) onIndexChanged;
  const DashboardPage({super.key, required this.onIndexChanged});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  // Key for RefreshIndicator
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> _onRefresh() async {
    // Invalidate providers to force refresh
    ref.invalidate(hostelsByOwnerProvider);
    
    // Wait a bit for the streams to update
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserId = authState.value?.id;

    if (currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final hostels = ref.watch(hostelsByOwnerProvider(currentUserId)).value ?? [];
    final totalHostels = hostels.length;
    final hostelIds = hostels.map((h) => h.id).toList();
    final bookingService = BookingService();

    return Scaffold(
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _onRefresh,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(ref),
                SizedBox(height: 24.h),
                StreamBuilder<List<dynamic>>(
                  stream: _getBookingStatsStream(currentUserId, bookingService),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final stats = snapshot.data!;
                    final activeBookings = stats[0] as int;
                    final pendingRequests = stats[1] as int;
                    final totalEarnings = stats[2] as double;

                    return Column(
                      children: [
                        _buildQuickStats(
                          totalHostels: totalHostels,
                          activeBookings: activeBookings,
                          pendingRequests: pendingRequests,
                          totalEarnings: totalEarnings,
                        ),
                        SizedBox(height: 24.h),
                        _buildOccupancySection(hostelIds),
                        SizedBox(height: 24.h),
                        _buildRecentActivity(currentUserId, bookingService),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<List<dynamic>> _getBookingStatsStream(
    String ownerId,
    BookingService bookingService,
  ) async* {
    await for (final bookings in bookingService.getBookingsByOwnerStream(ownerId)) {
      try {
        final activeBookings = bookings
            .where((b) => b.status == 'confirmed' || b.status == 'checked-in')
            .length;
        final pendingRequests = bookings.where((b) => b.status == 'pending').length;
        final totalEarnings = bookings
            .where((b) => b.status == 'confirmed' || b.status == 'checked-in')
            .fold(0.0, (sum, booking) => sum + booking.totalPrice);
        yield [activeBookings, pendingRequests, totalEarnings];
      } catch (e) {
        AppLogger.error('Error getting owner booking stats', e);
        yield [0, 0, 0.0];
      }
    }
  }

  Widget _buildWelcomeSection(WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final userName = user?.fullName.split(' ').first ?? 'Hostel Owner';
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
           
            // SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $userName!',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Manage your hostels and track performance',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
  return Column(
    children: [
      Row(
        children: [
          Expanded(child: _buildStatCard(title: 'Total Hostels', value: totalHostels.toString(), icon: Icons.business, color: Colors.blue)),
          SizedBox(width: 16.w),
          Expanded(child: _buildStatCard(title: 'Active Bookings', value: activeBookings.toString(), icon: Icons.calendar_today, color: Colors.green)),
        ],
      ),
      SizedBox(height: 16.h),
      Row(
        children: [
          Expanded(child: _buildStatCard(title: 'Pending Requests', value: pendingRequests.toString(), icon: Icons.pending_actions, color: Colors.orange)),
          SizedBox(width: 16.w),
          Expanded(child: _buildStatCard(title: 'Total Earnings', value: 'GHS ${totalEarnings.toStringAsFixed(0)}', icon: Icons.attach_money, color: Colors.purple)),
        ],
      ),
    ],
  );
}

Widget _buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      gradient: LinearGradient(
        colors: [
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Card(
      color: Colors.white.withValues(alpha: 0.85),
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
                color: color.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
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

            // Value
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

  // ---------------------------------------------------------------------------
  // Occupancy section
  // ---------------------------------------------------------------------------

  Widget _buildOccupancySection(List<String> hostelIds) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    if (hostelIds.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Occupancy',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        StreamBuilder<List<RoomModel>>(
          stream: RoomService().getRoomsByHostelIds(hostelIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }
            final rooms = snapshot.data ?? [];
            if (rooms.isEmpty) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No rooms added yet',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                    ),
                  ),
                ),
              );
            }

            final totalSpaces =
                rooms.fold(0, (sum, r) => sum + r.totalSpaces);
            final occupied =
                rooms.fold(0, (sum, r) => sum + r.occupiedSpaces);
            final available =
                rooms.fold(0, (sum, r) => sum + r.availableSpaces);
            final rate =
                totalSpaces > 0 ? occupied / totalSpaces : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards — reuse existing _buildStatCard style
                if (isMobile)
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 40.w - 12.w) / 2,
                        child: _buildStatCard(title: 'Total Spaces', value: totalSpaces.toString(), icon: Icons.hotel, color: Colors.blue),
                      ),
                      SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 40.w - 12.w) / 2,
                        child: _buildStatCard(title: 'Occupied', value: occupied.toString(), icon: Icons.person, color: Colors.red),
                      ),
                      SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 40.w - 12.w) / 2,
                        child: _buildStatCard(title: 'Available', value: available.toString(), icon: Icons.meeting_room, color: Colors.green),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(title: 'Total Spaces', value: totalSpaces.toString(), icon: Icons.hotel, color: Colors.blue)),
                      SizedBox(width: 12.w),
                      Expanded(child: _buildStatCard(title: 'Occupied', value: occupied.toString(), icon: Icons.person, color: Colors.red)),
                      SizedBox(width: 12.w),
                      Expanded(child: _buildStatCard(title: 'Available', value: available.toString(), icon: Icons.meeting_room, color: Colors.green)),
                    ],
                  ),
                SizedBox(height: 16.h),

                // Occupancy rate bar
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Occupancy Rate',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: _occupancyColor(rate)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '${(rate * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _occupancyColor(rate),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: rate,
                            minHeight: 10.h,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                                _occupancyColor(rate)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Per-room breakdown
                if (rooms.any((r) => r.totalSpaces > 0)) ...[
                  SizedBox(height: 12.h),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Per Room Type',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 12.h),
                          ...rooms
                              .where((r) => r.totalSpaces > 0)
                              .map(_buildRoomOccupancyRow),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Color _occupancyColor(double rate) {
    if (rate >= 0.9) return Colors.red;
    if (rate >= 0.7) return Colors.orange;
    return Colors.green;
  }

  Widget _buildRoomOccupancyRow(RoomModel room) {
    final rate =
        room.totalSpaces > 0 ? room.occupiedSpaces / room.totalSpaces : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  room.type,
                  style: TextStyle(fontSize: 13.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                children: [
                  Text(
                    '${room.occupiedSpaces}/${room.totalSpaces}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: room.isFull ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  if (room.isFull) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Full',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 6.h,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(_occupancyColor(rate)),
            ),
          ),
        ],
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
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => widget.onIndexChanged(2),
              child: const Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        StreamBuilder<List<dynamic>>(
          stream: _getRecentActivityStream(ownerId, bookingService),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading activity'));
            }
            final activities = snapshot.data ?? [];
            if (activities.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_note, size: 64.w, color: Colors.grey[400]),
                      SizedBox(height: 16.h),
                      Text(
                        'No recent activity',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Activity will appear here',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (int i = 0; i < activities.length; i++) ...[
                  if (i > 0) SizedBox(height: 8.h),
                  _buildActivityItem(
                    title: activities[i]['title'],
                    time: activities[i]['time'],
                    icon: activities[i]['icon'],
                    color: activities[i]['color'],
                    booking: activities[i]['booking'],
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Stream<List<Map<String, dynamic>>> _getRecentActivityStream(
    String ownerId, 
    BookingService bookingService
  ) async* {
    await for (final List<BookingModel> bookings in bookingService.getBookingsByOwnerStream(ownerId)) {
      try {
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
        AppLogger.error('Error getting owner recent activity', e);
        yield [];
      }
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
            color: color.withValues(alpha: 0.1),
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
        onTap: booking != null ? () => widget.onIndexChanged(2) : null,
      ),
    );
  }

}