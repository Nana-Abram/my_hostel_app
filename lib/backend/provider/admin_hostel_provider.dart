import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

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

  Stream<List<HostelModel>> getHostelsStream() {
    return _firestore
        .collection('hostels')
        .snapshots()
        .map((snapshot) {
      AppLogger.info('Admin hostels snapshot count: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
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

      return {
        'totalHostels': totalHostels,
        'verifiedHostels': verifiedHostels,
        'pendingHostels': pendingHostels,
        'suspendedHostels': suspendedHostels,
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