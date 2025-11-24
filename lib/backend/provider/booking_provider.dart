// providers/booking_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) => BookingService());

final bookingsByOwnerProvider = StreamProvider.family<List<BookingModel>, String>((ref, ownerId) {
  final service = ref.read(bookingServiceProvider);
  return service.getBookingsByOwner(ownerId);
});

final bookingStatsProvider = FutureProvider.family<Map<String, int>, String>((ref, ownerId) {
  final service = ref.read(bookingServiceProvider);
  return service.getBookingStats(ownerId);
});

// Filtered bookings provider
final filteredBookingsProvider = Provider.family<List<BookingModel>, String>((ref, ownerId) {
  final bookingsAsync = ref.watch(bookingsByOwnerProvider(ownerId));
  return bookingsAsync.maybeWhen(
    data: (bookings) => bookings,
    orElse: () => [],
  );
});

// Bookings by status
final bookingsByStatusProvider = Provider.family<List<BookingModel>, Map<String, dynamic>>((ref, params) {
  final ownerId = params['ownerId'];
  final status = params['status'];
  final bookingsAsync = ref.watch(bookingsByOwnerProvider(ownerId));
  
  return bookingsAsync.maybeWhen(
    data: (bookings) => bookings.where((booking) => booking.status == status).toList(),
    orElse: () => [],
  );
});