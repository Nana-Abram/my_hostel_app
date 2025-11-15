import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/backend/service/hostel_service.dart';

final hostelServiceProvider = Provider((ref) => HostelService());

final hostelsStreamProvider = StreamProvider<List<HostelModel>>((ref) {
  final service = ref.read(hostelServiceProvider);


  return service.getAllHostelsStream();
});

final hostelsFutureProvider = FutureProvider<List<HostelModel>>((ref) {
  final service = ref.read(hostelServiceProvider);
  return service.getAllHostels();
});

final filteredHostelsProvider = Provider<List<HostelModel>>((ref) {
  final filter = ref.watch(filterProvider);
  final hostelsAsync = ref.watch(hostelsStreamProvider);
  final roomsAsync = ref.watch(roomsStreamProvider);

  if (hostelsAsync.asData == null || roomsAsync.asData == null) {
    return [];
  }

  final hostels = hostelsAsync.asData!.value;
  final rooms = roomsAsync.asData!.value;

  return hostels.where((hostel) {
    // Get all rooms for this hostel
    final hostelRooms = rooms.where((room) => room.hostelId == hostel.id).toList();
    
    // If no rooms found for this hostel, skip it
    if (hostelRooms.isEmpty) return false;

    // HOSTEL-LEVEL FILTERS
    // UPDATED: Partial matching for campus
    final campusMatch = filter.campus == null || 
                        filter.campus!.isEmpty || 
                        hostel.campus.toLowerCase().contains(filter.campus!.toLowerCase());

    final amenitiesMatch = filter.amenities.isEmpty || 
                          filter.amenities.every(hostel.amenities.contains);

    // ROOM-LEVEL FILTERS - Only consider AVAILABLE rooms
    final filteredRooms = hostelRooms.where((room) {
      if (!room.available || room.availableRooms <= 0) return false;
      
      final roomTypeMatch = filter.roomType == null || room.type == filter.roomType;
      final genderMatch = filter.gender == null || room.gender == filter.gender;
      final priceMatch = filter.maxPrice == null || room.price <= filter.maxPrice!;
      
      return roomTypeMatch && genderMatch && priceMatch;
    }).toList();

    return campusMatch && amenitiesMatch && filteredRooms.isNotEmpty;
  }).toList();
});
