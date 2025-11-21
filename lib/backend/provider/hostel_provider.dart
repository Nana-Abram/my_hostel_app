import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/backend/service/hostel_service.dart';

final hostelServiceProvider = Provider<HostelService>((ref) => HostelService());

final hostelsStreamProvider = StreamProvider<List<HostelModel>>((ref) {
  final service = ref.read(hostelServiceProvider);
  return service.getAllHostelsStream();
});

// ADD: Provider for hostels by owner
final hostelsByOwnerProvider = StreamProvider.family<List<HostelModel>, String>((ref, ownerId) {
  final service = ref.read(hostelServiceProvider);
  return service.getHostelsByOwner(ownerId);
});

final hostelsFutureProvider = FutureProvider<List<HostelModel>>((ref) {
  final service = ref.read(hostelServiceProvider);
  return service.getAllHostels();
});

final hostelByIdProvider = StreamProvider.family<HostelModel?, String>((ref, hostelId) {
  final service = ref.read(hostelServiceProvider);
  return service.getHostelByIdStream(hostelId);
});

// ADD: Notifier for CRUD operations
class HostelNotifier extends StateNotifier<AsyncValue<void>> {
  final HostelService _hostelService;
  
  HostelNotifier(this._hostelService) : super(const AsyncValue.data(null));

  // Add hostel
  Future<void> addHostel(HostelModel hostel) async {
    state = const AsyncValue.loading();
    try {
      await _hostelService.addHostel(hostel);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Update hostel
  Future<void> updateHostel(String hostelId, HostelModel hostel) async {
    state = const AsyncValue.loading();
    try {
      await _hostelService.updateHostel(hostelId, hostel);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Delete hostel
  Future<void> deleteHostel(String hostelId) async {
    state = const AsyncValue.loading();
    try {
      await _hostelService.deleteHostel(hostelId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
// ADD: Notifier provider
final hostelNotifierProvider = StateNotifierProvider<HostelNotifier, AsyncValue<void>>((ref) {
  final service = ref.read(hostelServiceProvider);
  return HostelNotifier(service);
});



final filteredHostelsProvider = Provider<List<HostelModel>>((ref) {
  final filter = ref.watch(filterProvider);
  final hostelsAsync = ref.watch(hostelsStreamProvider);
  final roomsAsync = ref.watch(roomsStreamProvider);

  // Handle loading/error states
  if (hostelsAsync.isLoading || roomsAsync.isLoading) {
    return [];
  }

  if (hostelsAsync.hasError || roomsAsync.hasError) {
    // You might want to handle errors differently
    return [];
  }

  final hostels = hostelsAsync.value ?? [];
  final rooms = roomsAsync.value ?? [];

  return hostels.where((hostel) {
    // Get all rooms for this hostel
    final hostelRooms = rooms.where((room) => room.hostelId == hostel.id).toList();
    
    // If no rooms found for this hostel, skip it
    if (hostelRooms.isEmpty) return false;

    // HOSTEL-LEVEL FILTERS
    final campusMatch = filter.campus == null || 
                        filter.campus!.isEmpty || 
                        hostel.campus.toLowerCase().contains(filter.campus!.toLowerCase());

    final amenitiesMatch = filter.amenities.isEmpty || 
                          filter.amenities.every(hostel.amenities.contains);

    // ROOM-LEVEL FILTERS - Only consider AVAILABLE rooms
    final hasAvailableRooms = hostelRooms.any((room) {
      if (!room.available || room.availableRooms <= 0) return false;
      
      final roomTypeMatch = filter.roomType == null || room.type == filter.roomType;
      final genderMatch = filter.gender == null || room.gender == filter.gender;
      final priceMatch = filter.maxPrice == null || room.price <= filter.maxPrice!;
      
      return roomTypeMatch && genderMatch && priceMatch;
    });

    return campusMatch && amenitiesMatch && hasAvailableRooms;
  }).toList();
});

// // Optional: Provider for hostel owner's hostels
// final myHostelsProvider = StreamProvider<List<HostelModel>>((ref) {
//   final service = ref.read(hostelServiceProvider);
//   final hostelsStream = service.getAllHostelsStream();
  
//   // You'll need to get the current user ID and filter by ownerId
//   // This assumes your HostelModel has an ownerId field
//   // return hostelsStream.map((hostels) => hostels.where((hostel) => hostel.ownerId == currentUserId).toList());
//   return hostelsStream; // Placeholder - you'll need to implement the filtering
// });