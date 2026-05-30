import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;

  Future<void> addRoom(RoomModel room) async {
    await _db.collection('rooms').add(room.toMap());
  }

  Future<List<RoomModel>> getRoomsByHostel(String hostelId) async {
    final snapshot = await _db
        .collection('rooms')
        .where('hostelId', isEqualTo: hostelId)
        .get();

    return snapshot.docs
        .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ✅ FIXED: Get single room by document ID
  Future<RoomModel?> getRoomById(String roomId) async {
    try {
      final doc = await _db.collection('rooms').doc(roomId).get();
      
      if (doc.exists) {
        return RoomModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error fetching room by ID', e);
      return null;
    }
  }

  //  Stream version for real-time updates
  Stream<RoomModel?> getRoomByIdStream(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots().map((doc) {
      if (doc.exists) {
        return RoomModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Stream<List<RoomModel>> getAllRoomsStream() {
    return _db.collection('rooms').snapshots().map((snapshot) {
      AppLogger.info('Rooms snapshot length: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add this to RoomService for real-time room updates by hostel
Stream<List<RoomModel>> getRoomsByHostelStream(String hostelId) {
  return _db
      .collection('rooms')
      .where('hostelId', isEqualTo: hostelId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList());
}

  Future<void> updateRoom(String roomId, RoomModel room) async {
    try {
      await _db.collection('rooms').doc(roomId).update(room.toMap());
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }
}