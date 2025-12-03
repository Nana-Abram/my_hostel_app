import 'package:my_hostel_app/backend/model/booking_model.dart';

class StudentDashboardData {
  final int totalBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final double totalSpent;
  final List<BookingModel> recentBookings;
  final List<BookingModel> upcomingBookings;

  StudentDashboardData({
    required this.totalBookings,
    required this.pendingBookings,
    required this.confirmedBookings,
    required this.totalSpent,
    required this.recentBookings,
    required this.upcomingBookings,
  });

  factory StudentDashboardData.empty() {
    return StudentDashboardData(
      totalBookings: 0,
      pendingBookings: 0,
      confirmedBookings: 0,
      totalSpent: 0,
      recentBookings: [],
      upcomingBookings: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalBookings': totalBookings,
      'pendingBookings': pendingBookings,
      'confirmedBookings': confirmedBookings,
      'totalSpent': totalSpent,
      'recentBookings': recentBookings.map((b) => b.toMap()).toList(),
      'upcomingBookings': upcomingBookings.map((b) => b.toMap()).toList(),
    };
  }
}