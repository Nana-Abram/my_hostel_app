// services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all bookings for hostels owned by a specific user
  Stream<List<BookingModel>> getBookingsByOwner(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId) // We'll need to add ownerId to bookings
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get bookings by hostel ID
  Stream<List<BookingModel>> getBookingsByHostel(String hostelId) {
    return _firestore
        .collection('bookings')
        .where('hostelId', isEqualTo: hostelId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Get booking statistics for dashboard
  Future<Map<String, int>> getBookingStats(String ownerId) async {
    final bookings = await _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    final now = DateTime.now();
    
    return {
      'total': bookings.docs.length,
      'pending': bookings.docs.where((doc) => doc.data()['status'] == 'pending').length,
      'confirmed': bookings.docs.where((doc) => doc.data()['status'] == 'confirmed').length,
      'checkedIn': bookings.docs.where((doc) => doc.data()['status'] == 'checked-in').length,
      'todayCheckIn': bookings.docs.where((doc) {
        final checkIn = (doc.data()['checkInDate'] as Timestamp).toDate();
        return doc.data()['status'] == 'confirmed' && 
               checkIn.year == now.year && 
               checkIn.month == now.month && 
               checkIn.day == now.day;
      }).length,
    };
  }
}