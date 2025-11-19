import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';

// Use HostelModel instead of Map
final hostelsProvider = StreamProvider<List<HostelModel>>((ref) {
  final hostelsService = HostelsService();
  return hostelsService.getHostelsStream();
});

final hostelsStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final hostelsService = HostelsService();
  return await hostelsService.getHostelsStats();
});

class HostelsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Return Stream of HostelModel objects
  Stream<List<HostelModel>> getHostelsStream() {
    return _firestore
        .collection('hostels')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        print("====$snapshot");
        return HostelModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  
  }

  Future<Map<String, dynamic>> getHostelsStats() async {
    try {
      final hostelsSnapshot = await _firestore.collection('hostels').get();
      final hostels = hostelsSnapshot.docs.map((doc) => HostelModel.fromMap(doc.data(), doc.id)).toList();

      int totalHostels = hostels.length;
      int verifiedHostels = hostels.where((hostel) => hostel.status.toLowerCase() == 'verified').length;
      int pendingHostels = hostels.where((hostel) => hostel.status.toLowerCase() == 'pending').length;
      int suspendedHostels = hostels.where((hostel) => hostel.status.toLowerCase() == 'suspended').length;

      // // Calculate average occupancy
      // double totalOccupancy = 0;
      // for (final hostel in hostels) {
      //   totalOccupancy += hostel.occupancyRate;
      // }
      // double averageOccupancy = totalHostels > 0 ? totalOccupancy / totalHostels : 0;

      return {
        'totalHostels': totalHostels,
        'verifiedHostels': verifiedHostels,
        'pendingHostels': pendingHostels,
        'suspendedHostels': suspendedHostels,
        // 'averageOccupancy': averageOccupancy,
      };
    } catch (e) {
      throw 'Failed to fetch hostels stats: $e';
    }
  }

  Future<void> verifyHostel(String hostelId) async {
    try {
      await _firestore.collection('hostels').doc(hostelId).update({
        'status': 'verified',
        'verifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to verify hostel: $e';
    }
  }

  Future<void> suspendHostel(String hostelId) async {
    try {
      await _firestore.collection('hostels').doc(hostelId).update({
        'status': 'suspended',
      });
    } catch (e) {
      throw 'Failed to suspend hostel: $e';
    }
  }

  Future<void> deleteHostel(String hostelId) async {
    try {
      await _firestore.collection('hostels').doc(hostelId).delete();
    } catch (e) {
      throw 'Failed to delete hostel: $e';
    }
  }
}