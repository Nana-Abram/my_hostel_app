import 'package:my_hostel_app/backend/model/dashboard_model.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';

class DashboardService {
  final BookingService _bookingService;

  DashboardService(this._bookingService);

  // Get student dashboard data
  Future<StudentDashboardData> getStudentDashboardData(String userId) async {
    try {
      // Get all bookings for the user
      final bookings = await _bookingService.getBookingsByUserOnce(userId);
      
      // Calculate statistics
      final totalBookings = bookings.length;
      final pendingBookings = bookings.where((b) => b.status == 'pending').length;
      final confirmedBookings = bookings.where((b) => b.status == 'confirmed').length;
      final totalSpent = bookings.fold(0.0, (sum, booking) => sum + booking.totalPrice);
      
      // Get recent bookings (last 5)
      final recentBookings = bookings
          .where((b) => b.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30))))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Get upcoming bookings (check-in within next 30 days)
      final upcomingBookings = bookings
          .where((b) => 
            b.status == 'confirmed' && 
            b.checkInDate.isAfter(DateTime.now()) &&
            b.checkInDate.isBefore(DateTime.now().add(const Duration(days: 30)))
          )
          .toList()
        ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

      return StudentDashboardData(
        totalBookings: totalBookings,
        pendingBookings: pendingBookings,
        confirmedBookings: confirmedBookings,
        totalSpent: totalSpent,
        recentBookings: recentBookings.take(5).toList(),
        upcomingBookings: upcomingBookings,
      );
      
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return StudentDashboardData.empty();
    }
  }


  // Get dashboard data stream for real-time updates
  Stream<StudentDashboardData> getStudentDashboardStream(String userId) {
    return _bookingService.getBookingsByUser(userId).map((bookings) {
      // Calculate statistics from stream
      final totalBookings = bookings.length;
      final pendingBookings = bookings.where((b) => b.status == 'pending').length;
      final confirmedBookings = bookings.where((b) => b.status == 'confirmed').length;
      final totalSpent = bookings.fold(0.0, (sum, booking) => sum + booking.totalPrice);
      
      // Get recent bookings
      final recentBookings = bookings
          .where((b) => b.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30))))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Get upcoming bookings
      final upcomingBookings = bookings
          .where((b) => 
            b.status == 'confirmed' && 
            b.checkInDate.isAfter(DateTime.now()) &&
            b.checkInDate.isBefore(DateTime.now().add(const Duration(days: 30)))
          )
          .toList()
        ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

      return StudentDashboardData(
        totalBookings: totalBookings,
        pendingBookings: pendingBookings,
        confirmedBookings: confirmedBookings,
        totalSpent: totalSpent,
        recentBookings: recentBookings.take(5).toList(),
        upcomingBookings: upcomingBookings,
      );
    });
  }
}