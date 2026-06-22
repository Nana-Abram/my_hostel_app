import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/ui/core/app_logger.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;

  Future<void> addRoom(RoomModel room) async {
    await _db.collection('rooms').add(room.toMap());
  }

  // Cache-first (falls back to server if there's no cached result yet).
  Future<List<RoomModel>> getRoomsByHostel(String hostelId) async {
    final query = _db.collection('rooms').where('hostelId', isEqualTo: hostelId);
    final snapshot = await query
        .get(const GetOptions(source: Source.cache))
        .catchError((_) async => await query.get());

    return snapshot.docs
        .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ✅ FIXED: Get single room by document ID (cache-first)
  Future<RoomModel?> getRoomById(String roomId) async {
    try {
      final ref = _db.collection('rooms').doc(roomId);
      final doc = await ref
          .get(const GetOptions(source: Source.cache))
          .catchError((_) => ref.get());

      if (doc.exists && doc.data() != null) {
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
      if (doc.exists && doc.data() != null) {
        return RoomModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Stream<List<RoomModel>> getAllRoomsStream() {
    return _db.collection('rooms').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<RoomModel>> getRoomsByHostelStream(String hostelId) {
    return _db
        .collection('rooms')
        .where('hostelId', isEqualTo: hostelId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Streams rooms belonging to any of the given hostel IDs (Firestore `in` limit: 30).
  Stream<List<RoomModel>> getRoomsByHostelIds(List<String> hostelIds) {
    if (hostelIds.isEmpty) return Stream.value([]);
    return _db
        .collection('rooms')
        .where('hostelId', whereIn: hostelIds.take(30).toList())
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

  /// One-time migration: sets occupiedSpaces on every room by counting its
  /// confirmed / checked-in bookings in Firestore.
  ///
  /// Call this once from the admin dashboard after deploying the new fields.
  Future<void> migrateRoomsOccupancy() async {
    final roomsSnap = await _db.collection('rooms').get();
    final batch = _db.batch();

    for (final roomDoc in roomsSnap.docs) {
      final confirmedSnap = await _db
          .collection('bookings')
          .where('roomId', isEqualTo: roomDoc.id)
          .where('status', whereIn: ['confirmed', 'checked-in'])
          .get();

      final occupied = confirmedSnap.docs.length;
      final data = roomDoc.data();
      final capacity = (data['capacity'] as num?)?.toInt() ?? 1;
      final roomCount = (data['availableRooms'] as num?)?.toInt() ?? 0;
      final total = capacity * roomCount;
      final isFull = total > 0 && occupied >= total;

      batch.update(roomDoc.reference, {
        'occupiedSpaces': occupied,
        'roomStatus': isFull ? 'full' : 'available',
        'available': !isFull,
      });
    }

    await batch.commit();
    AppLogger.info('Room occupancy migration complete — ${roomsSnap.docs.length} rooms updated.');
  }
}