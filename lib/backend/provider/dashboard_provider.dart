import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_hostel_app/backend/model/dashboard_model.dart';
import 'package:my_hostel_app/backend/provider/booking_provider.dart';
import 'package:my_hostel_app/backend/service/dashboard_service.dart';

// Dashboard service provider
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  return DashboardService(bookingService);
});

// Student dashboard data provider
final studentDashboardProvider = StreamProvider.autoDispose.family<StudentDashboardData, String>((ref, userId) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getStudentDashboardStream(userId);
});

// Dashboard loading state
final dashboardLoadingProvider = StateProvider<bool>((ref) => false);