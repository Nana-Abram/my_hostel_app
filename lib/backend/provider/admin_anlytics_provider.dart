import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final analyticsService = AnalyticsService();
  return await analyticsService.getAnalyticsData();
});

class AnalyticsService {
  Future<Map<String, dynamic>> getAnalyticsData() async {
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