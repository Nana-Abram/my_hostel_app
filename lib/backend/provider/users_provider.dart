import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/auth_model.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

final usersProvider = StreamProvider<List<UserModel>>((ref) {
  final usersService = UsersService();
  return usersService.getUsersStream();
});

final usersStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final usersService = UsersService();
  return await usersService.getUsersStats();
});

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get real-time stream of all users
  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

// Get users statistics
Future<Map<String, dynamic>> getUsersStats() async {
  try {
    final usersSnapshot = await _firestore.collection('users').get();
    final hostelsSnapshot = await _firestore.collection('hostels').get();
    final bookingsSnapshot = await _firestore.collection('bookings').get();

    final users = usersSnapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    final hostels = hostelsSnapshot.docs.map((doc) => HostelModel.fromMap(doc.data(), doc.id)).toList();
    final bookings = bookingsSnapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();

    int totalUsers = users.length;
    int students = users.where((user) => user.role == UserRole.student).length;
    int hostelOwners = users.where((user) => user.role == UserRole.hostelOwner).length;
    int admins = users.where((user) => user.role == UserRole.admin).length;
    int verifiedUsers = users.where((user) => user.isEmailVerified).length;

    int totalHostels = hostels.length;
    int totalBookings = bookings.length;
    
    // Calculate total earnings from confirmed bookings
    double totalEarnings = 0;
    int confirmedBookings = 0;
    int pendingBookings = 0;
    int cancelledBookings = 0;
    int checkedInBookings = 0;
    
    for (var booking in bookings) {
      if (booking.status == 'confirmed') {
        totalEarnings += booking.totalPrice;
        confirmedBookings++;
      } else if (booking.status == 'pending') {
        pendingBookings++;
      } else if (booking.status == 'cancelled') {
        cancelledBookings++;
      } else if (booking.status == 'checked-in') {
        totalEarnings += booking.totalPrice; // Also count checked-in bookings
        checkedInBookings++;
        confirmedBookings++; // Add to confirmed count as well
      }
    }
    
    // Calculate average booking value
    double averageBookingValue = (confirmedBookings + checkedInBookings) > 0 
        ? totalEarnings / (confirmedBookings + checkedInBookings) 
        : 0;

    return {
      'totalUsers': totalUsers,
      'students': students,
      'hostelOwners': hostelOwners,
      'admins': admins,
      'verifiedUsers': verifiedUsers,
      
      'totalHostels': totalHostels,
      'totalBookings': totalBookings,
      'totalEarnings': totalEarnings,
      'confirmedBookings': confirmedBookings,
      'pendingBookings': pendingBookings,
      'cancelledBookings': cancelledBookings,
      'checkedInBookings': checkedInBookings,
      'averageBookingValue': averageBookingValue,
      
      // Additional useful stats
      'bookingCompletionRate': totalBookings > 0 
          ? ((confirmedBookings + checkedInBookings) / totalBookings * 100).toStringAsFixed(1)
          : '0.0',
      'cancellationRate': totalBookings > 0 
          ? (cancelledBookings / totalBookings * 100).toStringAsFixed(1)
          : '0.0',
    };
  } catch (e) {
    AppLogger.error('Error fetching users stats', e);
    throw Exception('Failed to fetch users stats: $e');
  }
}

  // Search users
  Stream<List<UserModel>> searchUsers(String query) {
    return _firestore
        .collection('users')
        .orderBy('fullName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).where((user) {
        final name = user.fullName.toLowerCase();
        final email = user.email.toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || email.contains(searchQuery);
      }).toList();
    });
  }

  // Update user role
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.name,
      });
    } catch (e) {
      throw 'Failed to update user role: $e';
    }
  }

  // Verify user
  Future<void> verifyUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isEmailVerified': true,
      });
    } catch (e) {
      throw 'Failed to verify user: $e';
    }
  }

  // Update user fields
  Future<void> updateUser(String userId, Map<String, dynamic> fields) async {
    try {
      await _firestore.collection('users').doc(userId).update(fields);
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user: $e';
    }
  }
}