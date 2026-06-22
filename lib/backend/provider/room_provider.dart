import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/service/room_service.dart';

final roomServiceProvider = Provider((ref) => RoomService());

/// STREAM OF ALL ROOMS (Corrected!)
final roomsStreamProvider = StreamProvider.autoDispose<List<RoomModel>>((ref) {
  final service = ref.read(roomServiceProvider);  // FIXED HERE
  return service.getAllRoomsStream();
});

/// GET ROOMS FOR A SELECTED HOSTEL

final roomsByHostelProvider =
    FutureProvider.family<List<RoomModel>, String>((ref, hostelId) {
  final service = ref.read(roomServiceProvider);
  return service.getRoomsByHostel(hostelId);
});

// Add this to your room_provider.dart
final roomByIdProvider = FutureProvider.autoDispose.family<RoomModel?, String>((ref, roomId) async {
  final service = ref.read(roomServiceProvider); // You'll need to create this
  return await service.getRoomById(roomId);
});


//  Stream version for real-time updates
final roomByIdStreamProvider = StreamProvider.autoDispose.family<RoomModel?, String>((ref, roomId) {
  final service = ref.read(roomServiceProvider);
  return service.getRoomByIdStream(roomId);
});