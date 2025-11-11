import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';


class BookingService {
  final _db = FirebaseFirestore.instance;

  Future<String> createBooking(BookingModel booking) async {
    final ref = await _db.collection('bookings').add(booking.toMap());
    return ref.id; // return ID of booking
  }


  Future<List<BookingModel>> getBookingsForUser(String userId) async {
    final snapshot = await _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({
      "status": status,
    });
  }
}
