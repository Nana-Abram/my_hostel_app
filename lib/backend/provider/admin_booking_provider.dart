import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';

final allBookingsProvider = StreamProvider.autoDispose<List<BookingModel>>((ref) {
  return AdminBookingService().getAllBookingsStream();
});

final bookingStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return AdminBookingService().getBookingStats();
});

class AdminBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BookingModel>> getAllBookingsStream() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<Map<String, dynamic>> getBookingStats() async {
    try {
      final snapshot = await _firestore.collection('bookings').get();
      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();

      final total = bookings.length;
      final pending = bookings.where((b) => b.status == 'pending').length;
      final confirmed = bookings.where((b) => b.status == 'confirmed').length;
      final cancelled = bookings.where((b) => b.status == 'cancelled').length;
      final totalRevenue = bookings
          .where((b) => b.status == 'confirmed')
          .fold<double>(0, (acc, b) => acc + b.totalPrice);

      return {
        'total': total,
        'pending': pending,
        'confirmed': confirmed,
        'cancelled': cancelled,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw 'Failed to fetch booking stats: $e';
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    // Delegates to BookingService which uses a transaction to restore room inventory
    await BookingService().cancelBooking(bookingId);
  }

  Future<void> confirmBooking(String bookingId) async {
    // Delegates to BookingService which uses a transaction to decrement room inventory
    await BookingService().updateBookingStatus(bookingId, 'confirmed');
  }
}
