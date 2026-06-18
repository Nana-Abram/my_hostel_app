import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/service/notification_helper.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Booking creation
  // ---------------------------------------------------------------------------

  /// Creates a confirmed booking AND decrements room occupancy atomically.
  /// Throws a user-facing [String] if the room has no available spaces.
  Future<String> createConfirmedBookingWithInventory({
    required BookingModel booking,
    required String paymentReference,
  }) async {
    final bookingRef = _firestore.collection('bookings').doc();
    final roomRef = _firestore.collection('rooms').doc(booking.roomId);

    try {
      await _firestore.runTransaction((tx) async {
        final roomSnap = await tx.get(roomRef);
        if (!roomSnap.exists) throw 'Room not found.';

        final data = roomSnap.data()!;
        final capacity = (data['capacity'] as num?)?.toInt() ?? 1;
        final roomCount = (data['availableRooms'] as num?)?.toInt() ?? 0;
        final occupied = (data['occupiedSpaces'] as num?)?.toInt() ?? 0;
        final total = capacity * roomCount;

        if (total > 0 && occupied >= total) {
          throw 'No spaces available for this room type. Please choose another room.';
        }

        final newOccupied = occupied + 1;
        final isFull = total > 0 && newOccupied >= total;

        final confirmedBooking = BookingModel(
          id: bookingRef.id,
          hostelId: booking.hostelId,
          hostelName: booking.hostelName,
          userId: booking.userId,
          ownerId: booking.ownerId,
          userName: booking.userName,
          userEmail: booking.userEmail,
          userPhone: booking.userPhone,
          roomId: booking.roomId,
          roomType: booking.roomType,
          checkInDate: booking.checkInDate,
          paymentReference: paymentReference,
          totalPrice: booking.totalPrice,
          status: 'confirmed',
          createdAt: booking.createdAt,
          specialRequests: booking.specialRequests,
        );

        tx.set(bookingRef, confirmedBooking.toMap());
        tx.update(roomRef, {
          'occupiedSpaces': newOccupied,
          'roomStatus': isFull ? 'full' : 'available',
          'available': !isFull,
        });
      });

      return bookingRef.id;
    } catch (e) {
      if (e is String) rethrow;
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Creates a pending booking (no payment, no inventory change).
  Future<String> createBooking(BookingModel booking) async {
    try {
      final docRef = await _firestore.collection('bookings').add(booking.toMap());

      await NotificationHelper.sendNewBookingToOwner(
        ownerId: booking.ownerId,
        studentName: booking.userName,
        hostelName: booking.hostelName,
        bookingId: docRef.id,
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Status updates
  // ---------------------------------------------------------------------------

  /// Updates booking status and adjusts room inventory atomically.
  ///
  /// - pending → confirmed: decrements occupiedSpaces (checks availability first).
  /// - confirmed/checked-in → cancelled/rejected: restores occupiedSpaces.
  /// Throws a user-facing [String] when confirming a full room.
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);
    BookingModel? booking;

    try {
      await _firestore.runTransaction((tx) async {
        final bookingSnap = await tx.get(bookingRef);
        if (!bookingSnap.exists) throw Exception('Booking not found');

        booking = BookingModel.fromMap(bookingSnap.data()!, bookingId);
        final oldStatus = booking!.status;
        final roomRef = _firestore.collection('rooms').doc(booking!.roomId);

        final wasConfirmed = oldStatus == 'confirmed' || oldStatus == 'checked-in';
        final becomingConfirmed = newStatus == 'confirmed';
        final becomingTerminated = newStatus == 'cancelled' || newStatus == 'rejected';

        tx.update(bookingRef, {'status': newStatus});

        if (becomingConfirmed && !wasConfirmed) {
          // Owner manually confirming a pending booking — check + decrement.
          final roomSnap = await tx.get(roomRef);
          if (roomSnap.exists) {
            final data = roomSnap.data()!;
            final capacity = (data['capacity'] as num?)?.toInt() ?? 1;
            final roomCount = (data['availableRooms'] as num?)?.toInt() ?? 0;
            final occupied = (data['occupiedSpaces'] as num?)?.toInt() ?? 0;
            final total = capacity * roomCount;

            if (total > 0 && occupied >= total) {
              throw 'No spaces available for this room type. The room is fully booked.';
            }

            final newOccupied = occupied + 1;
            final isFull = total > 0 && newOccupied >= total;
            tx.update(roomRef, {
              'occupiedSpaces': newOccupied,
              'roomStatus': isFull ? 'full' : 'available',
              'available': !isFull,
            });
          }
        } else if (becomingTerminated && wasConfirmed) {
          // Restoring inventory for a confirmed booking being cancelled/rejected.
          final roomSnap = await tx.get(roomRef);
          if (roomSnap.exists) {
            final occupied = (roomSnap.data()!['occupiedSpaces'] as num?)?.toInt() ?? 0;
            final newOccupied = occupied > 0 ? occupied - 1 : 0;
            tx.update(roomRef, {
              'occupiedSpaces': newOccupied,
              'roomStatus': 'available',
              'available': true,
            });
          }
        }
      });

      // Send notifications outside the transaction (non-blocking).
      if (booking != null) {
        if (newStatus == 'confirmed') {
          await NotificationHelper.sendBookingConfirmationToStudent(
            userId: booking!.userId,
            hostelName: booking!.hostelName,
            bookingId: bookingId,
          );
        } else if (newStatus == 'rejected' || newStatus == 'cancelled') {
          await NotificationHelper.sendBookingRejectionToStudent(
            userId: booking!.userId,
            hostelName: booking!.hostelName,
            bookingId: bookingId,
          );
        }
      }
    } catch (e) {
      if (e is String) rethrow;
      throw Exception('Failed to update booking status: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Cancellation
  // ---------------------------------------------------------------------------

  /// Cancels a booking. Restores room inventory if the booking was confirmed.
  Future<void> cancelBooking(String bookingId) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    try {
      await _firestore.runTransaction((tx) async {
        final bookingSnap = await tx.get(bookingRef);
        if (!bookingSnap.exists) return;

        final booking = BookingModel.fromMap(bookingSnap.data()!, bookingId);
        tx.update(bookingRef, {'status': 'cancelled'});

        if (booking.status == 'confirmed' || booking.status == 'checked-in') {
          final roomRef = _firestore.collection('rooms').doc(booking.roomId);
          final roomSnap = await tx.get(roomRef);
          if (roomSnap.exists) {
            final occupied = (roomSnap.data()!['occupiedSpaces'] as num?)?.toInt() ?? 0;
            final newOccupied = occupied > 0 ? occupied - 1 : 0;
            tx.update(roomRef, {
              'occupiedSpaces': newOccupied,
              'roomStatus': 'available',
              'available': true,
            });
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  Stream<List<BookingModel>> getBookingsByOwner(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
          bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return bookings;
        });
  }

  Stream<List<BookingModel>> getBookingsByOwnerStream(String ownerId) {
    return getBookingsByOwner(ownerId);
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists && doc.data() != null) {
        return BookingModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  Stream<int> getPendingBookingsCount(String ownerId) {
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

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
        final ts = doc.data()['checkInDate'] as Timestamp?;
        if (ts == null) return false;
        final checkIn = ts.toDate();
        return doc.data()['status'] == 'confirmed' &&
            checkIn.year == now.year &&
            checkIn.month == now.month &&
            checkIn.day == now.day;
      }).length,
    };
  }

  Stream<List<BookingModel>> getBookingsByUser(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
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
        AppLogger.warn('Bookings composite index missing. Using client-side sorting fallback.');
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
              AppLogger.warn('Skipping malformed booking document: ${doc.id}');
              return null;
            }
          })
          .where((booking) => booking != null)
          .cast<BookingModel>()
          .toList();

      return bookings;
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        AppLogger.warn('Owner bookings index missing. Using fallback query for ownerId=$ownerId');
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
                  AppLogger.warn('Skipping malformed fallback booking document: ${doc.id}');
                  return null;
                }
              })
              .where((booking) => booking != null)
              .cast<BookingModel>()
              .toList();

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
