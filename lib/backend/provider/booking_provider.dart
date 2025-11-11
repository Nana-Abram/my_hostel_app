import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';


final bookingServiceProvider = Provider((ref) => BookingService());

final createBookingProvider =
    FutureProvider.family<String, BookingModel>((ref, booking) {
  final service = ref.read(bookingServiceProvider);
  return service.createBooking(booking);
});

final userBookingsProvider =
    FutureProvider.family<List<BookingModel>, String>((ref, userId) {
  final service = ref.read(bookingServiceProvider);
  return service.getBookingsForUser(userId);
});
