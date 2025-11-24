import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final analyticsService = AnalyticsService();
  return await analyticsService.getAnalyticsData();
});

class AnalyticsService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getAnalyticsData() async {
    // Implement your analytics data fetching logic
    // This is a mock implementation
    return {
      'totalRevenue': 45820,
      'newUsers': 1247,
      'totalBookings': 856,
      'occupancyRate': 0.78,
      'topHostels': [
        {'name': 'University Hostel', 'revenue': 12450},
        {'name': 'Student Comfort', 'revenue': 9820},
      ],
      'userDemographics': {
        'students': 65,
        'youngAdults': 25,
        'others': 10,
      },
    };
  }
}