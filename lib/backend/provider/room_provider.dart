import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/service/room_service.dart';


final roomServiceProvider = Provider((ref) => RoomService());


final roomsByHostelProvider =
    FutureProvider.family<List<RoomModel>, String>((ref, hostelId) {
  final service = ref.read(roomServiceProvider);
  return service.getRoomsByHostel(hostelId);
});
