import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/service/room_service.dart';

final roomServiceProvider = Provider((ref) => RoomService());

/// STREAM OF ALL ROOMS (Corrected!)
final roomsStreamProvider = StreamProvider<List<RoomModel>>((ref) {
  final service = ref.read(roomServiceProvider);  // FIXED HERE
  return service.getAllRoomsStream();
});

/// GET ROOMS FOR A SELECTED HOSTEL
final roomsByHostelProvider =
    FutureProvider.family<List<RoomModel>, String>((ref, hostelId) {
  final service = ref.read(roomServiceProvider);
  return service.getRoomsByHostel(hostelId);
});

