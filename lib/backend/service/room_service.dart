import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';


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

  Stream<List<RoomModel>> getAllRoomsStream() {
    return _db.collection('rooms').snapshots().map((snapshot) {
      print("Snap for rooms:${snapshot.docs.length}");
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList();
          
    });
  }

  // Future<void> updateRoomAvailability(String roomId, bool value) async {
  //   await _db.collection('rooms').doc(roomId).update({
  //     "available": value,
  //   });
  // }

  // In your RoomService class
Future<void> updateRoom(String roomId, RoomModel room) async {
  try {
    await _db.collection('rooms').doc(roomId).update(room.toMap());
  } catch (e) {
    throw Exception('Failed to update room: $e');
  }
}

}

