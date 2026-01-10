import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new booking with status "pending"
  Future<String> createBooking(BookingModel booking) async {
    try {
      final docRef = await _firestore.collection('bookings').add(booking.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

Stream<List<BookingModel>> getBookingsByOwner(String ownerId) {
  return _firestore
      .collection('bookings')
      .where('ownerId', isEqualTo: ownerId)
      //  .orderBy('createdAt', descending: true) // Remove this temporarily
      .snapshots()
      .map((snapshot) {
        final bookings = snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();
        // Sort client-side
        bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return bookings;
      });
}

// Alias for clarity in dashboard
Stream<List<BookingModel>> getBookingsByOwnerStream(String ownerId) {
  return getBookingsByOwner(ownerId);
}

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Update booking status (for owners to confirm/reject)
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Cancel booking (for users)
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Get pending bookings count for owner
  Stream<int> getPendingBookingsCount(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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


// In getBookingsByUser method
Stream<List<BookingModel>> getBookingsByUser(String userId) {
  return _firestore
      .collection('bookings')
      .where('userId', isEqualTo: userId)
      .snapshots()  // Removed .orderBy('createdAt', descending: true)
      .map((snapshot) {
        final bookings = snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();
        // Sort client-side instead
        bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return bookings;
      });
}

Future<List<BookingModel>> getBookingsByUserOnce(String userId) async {
  try {
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  } on FirebaseException catch (e) {
    if (e.code == 'failed-precondition') {
      print('Index not created yet. Please create the composite index.');
      print('Or use the client-side sorting approach.');
      // Fallback to client-side sorting
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();
      
      final bookings = querySnapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
      
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    }
    throw Exception('Failed to get user bookings: $e');
  } catch (e) {
    throw Exception('Failed to get user bookings: $e');
  }
}


// Get confirmed bookings by owner ID (for earnings calculation)
Stream<List<BookingModel>> getConfirmedBookingsByOwner(String ownerId) {
  return _firestore
      .collection('bookings')
      .where('ownerId', isEqualTo: ownerId)
      .where('status', whereIn: ['confirmed', 'checked-in'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList());
}

// Get confirmed bookings by owner ID once (for initial load)
Future<List<BookingModel>> getConfirmedBookingsByOwnerOnce(String ownerId) async {
  try {
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', whereIn: ['confirmed', 'checked-in'])
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    throw Exception('Failed to get confirmed bookings: $e');
  }
}

// Get bookings by owner ID once (for dashboard and initial loads)
Future<List<BookingModel>> getBookingsByOwnerOnce(String ownerId) async {
  try {
    
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .get();
    
    
    final bookings = querySnapshot.docs
        .map((doc) {
          try {
            return BookingModel.fromMap(doc.data(), doc.id);
          } catch (e) {

            return null;
          }
        })
        .where((booking) => booking != null)
        .cast<BookingModel>()
        .toList();
    
    
    if (bookings.isNotEmpty) {
    }
    
    return bookings;
    
  } on FirebaseException catch (e) {
    
    // Fallback if index is not created yet
    if (e.code == 'failed-precondition') {
      
      try {
        final querySnapshot = await _firestore
            .collection('bookings')
            .where('ownerId', isEqualTo: ownerId)
            .get();
        
        final bookings = querySnapshot.docs
            .map((doc) {
              try {
                return BookingModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                return null;
              }
            })
            .where((booking) => booking != null)
            .cast<BookingModel>()
            .toList();
        
        // Sort client-side
        bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
        return bookings;
        
      } catch (fallbackError) {
        throw Exception('Failed to get owner bookings even with fallback: $fallbackError');
      }
    }
    
    throw Exception('Failed to get owner bookings: $e');
    
  } catch (e) {
    throw Exception('Failed to get owner bookings: $e');
  }
}

}
