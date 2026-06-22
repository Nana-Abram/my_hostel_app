import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get total platform statistics
  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      // Get all users count
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      
      // Get active users (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final activeUsers = usersSnapshot.docs
          .where((doc) {
            final lastActive = doc.data()['lastActive'] as Timestamp?;
            return lastActive != null && lastActive.toDate().isAfter(thirtyDaysAgo);
          })
          .length;

      // Get all bookings
      final bookingsSnapshot = await _firestore.collection('bookings').get();
      final totalBookings = bookingsSnapshot.docs.length;
      
      // Get confirmed bookings count and revenue
      double totalRevenue = 0;
      int confirmedBookings = 0;
      
      for (var doc in bookingsSnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'confirmed' || data['status'] == 'checked-in') {
          confirmedBookings++;
          totalRevenue += (data['totalPrice'] as num).toDouble();
        }
      }

      // Get all hostels count
      final hostelsSnapshot = await _firestore.collection('hostels').get();
      final totalHostels = hostelsSnapshot.docs.length;

      // Get active hostels (with at least one booking in last 30 days)
      final thirtyDaysAgoTimestamp = Timestamp.fromDate(thirtyDaysAgo);
      final activeHostelsQuery = await _firestore
          .collection('bookings')
          .where('createdAt', isGreaterThan: thirtyDaysAgoTimestamp)
          .get();
      
      final activeHostelIds = activeHostelsQuery.docs
          .map((doc) => doc.data()['hostelId'] as String)
          .toSet();
      
      final activeHostels = activeHostelIds.length;

      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'totalBookings': totalBookings,
        'confirmedBookings': confirmedBookings,
        'totalRevenue': totalRevenue,
        'totalHostels': totalHostels,
        'activeHostels': activeHostels,
        'occupancyRate': totalHostels > 0 ? (activeHostels / totalHostels * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      AppLogger.error('Error getting platform stats', e);
      throw Exception('Failed to get platform statistics: $e');
    }
  }

  // Get bookings over time for chart.
  // Fetches the whole date range in a single query and buckets client-side,
  // instead of firing one query per day/month (was up to 30 sequential reads).
  Future<List<Map<String, dynamic>>> getBookingsOverTime(String period) async {
    final now = DateTime.now();

    final DateTime rangeStart;
    final int bucketCount;
    switch (period) {
      case 'Last 7 Days':
        rangeStart = DateTime(now.year, now.month, now.day - 6);
        bucketCount = 7;
        break;
      case 'Last 30 Days':
        rangeStart = DateTime(now.year, now.month, now.day - 29);
        bucketCount = 30;
        break;
      case 'This Year':
        rangeStart = DateTime(now.year, 1, 1);
        bucketCount = 12;
        break;
      default:
        return [];
    }

    final querySnapshot = await _firestore
        .collection('bookings')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(rangeStart))
        .get();

    final createdDates = querySnapshot.docs
        .map((doc) => (doc.data()['createdAt'] as Timestamp?)?.toDate())
        .whereType<DateTime>()
        .toList();

    final data = <Map<String, dynamic>>[];

    if (period == 'This Year') {
      for (int i = 0; i < bucketCount; i++) {
        final monthStart = DateTime(now.year, i + 1, 1);
        final monthEnd = DateTime(now.year, i + 2, 1);
        final count = createdDates
            .where((d) => !d.isBefore(monthStart) && d.isBefore(monthEnd))
            .length;
        data.add({'label': _getMonthName(i + 1), 'value': count, 'date': monthStart});
      }
    } else {
      for (int i = bucketCount - 1; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        final nextDate = DateTime(date.year, date.month, date.day + 1);
        final count =
            createdDates.where((d) => !d.isBefore(date) && d.isBefore(nextDate)).length;
        data.add({
          'label': period == 'Last 7 Days' ? _getDayName(date.weekday) : '${date.day}',
          'value': count,
          'date': date,
        });
      }
    }

    return data;
  }

  // Get top performing hostels
  Future<List<Map<String, dynamic>>> getTopHostels(int limit) async {
    try {
      // Get all confirmed bookings
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('status', whereIn: ['confirmed', 'checked-in'])
          .get();
      
      // Calculate revenue and booking count per hostel in a single pass
      // (previously did a second full scan over bookingsSnapshot.docs per hostel).
      final Map<String, double> hostelRevenue = {};
      final Map<String, String> hostelNames = {};
      final Map<String, int> hostelBookingCount = {};

      for (var doc in bookingsSnapshot.docs) {
        final data = doc.data();
        final hostelId = data['hostelId'] as String;
        final hostelName = data['hostelName'] as String;
        final amount = (data['totalPrice'] as num).toDouble();

        hostelRevenue[hostelId] = (hostelRevenue[hostelId] ?? 0) + amount;
        hostelNames[hostelId] = hostelName;
        hostelBookingCount[hostelId] = (hostelBookingCount[hostelId] ?? 0) + 1;
      }

      // Sort by revenue
      final sortedHostels = hostelRevenue.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedHostels.take(limit).map((entry) {
        return {
          'id': entry.key,
          'name': hostelNames[entry.key] ?? 'Unknown Hostel',
          'revenue': entry.value,
          'bookingCount': hostelBookingCount[entry.key] ?? 0,
        };
      }).toList();
    } catch (e) {
      AppLogger.error('Error getting top hostels', e);
      return [];
    }
  }

  // Get user demographics
  Future<Map<String, dynamic>> getUserDemographics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      
      int students = 0;
      int owners = 0;
      int admins = 0;
      int totalActive = 0;
      
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] as String?;
        final lastActive = data['lastActive'] as Timestamp?;
        
        // Count by role
        if (role == 'student') {
          students++;
        } else if (role == 'hostelOwner') {
          owners++;
        } else if (role == 'admin') {
          admins++;
        }
        
        // Count active users
        if (lastActive != null && lastActive.toDate().isAfter(thirtyDaysAgo)) {
          totalActive++;
        }
      }
      
      final totalUsers = usersSnapshot.docs.length;
      
      return {
        'students': students,
        'owners': owners,
        'admins': admins,
        'totalUsers': totalUsers,
        'activeUsers': totalActive,
        'studentPercentage': totalUsers > 0 ? (students / totalUsers * 100).toStringAsFixed(1) : '0.0',
        'ownerPercentage': totalUsers > 0 ? (owners / totalUsers * 100).toStringAsFixed(1) : '0.0',
        'activePercentage': totalUsers > 0 ? (totalActive / totalUsers * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      AppLogger.error('Error getting user demographics', e);
      return {
        'students': 0,
        'owners': 0,
        'admins': 0,
        'totalUsers': 0,
        'activeUsers': 0,
        'studentPercentage': '0.0',
        'ownerPercentage': '0.0',
        'activePercentage': '0.0',
      };
    }
  }

  // Helper methods
  String _getDayName(int weekday) {
    return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][weekday % 7];
  }

  String _getMonthName(int month) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
  }
}