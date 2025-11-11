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

  Future<void> updateRoomAvailability(String roomId, bool value) async {
    await _db.collection('rooms').doc(roomId).update({
      "available": value,
    });
  }
}
