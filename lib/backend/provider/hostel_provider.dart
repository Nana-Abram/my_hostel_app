import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/filter_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/backend/service/hostel_service.dart';

final hostelServiceProvider = Provider<HostelService>((ref) => HostelService());

final hostelsStreamProvider = StreamProvider.autoDispose<List<HostelModel>>((ref) {
  final service = ref.read(hostelServiceProvider);
  return service.getAllHostelsStream();
});

// ADD: Provider for hostels by owner
final hostelsByOwnerProvider = StreamProvider.autoDispose.family<List<HostelModel>, String>((ref, ownerId) {
  final service = ref.read(hostelServiceProvider);
  return service.getHostelsByOwner(ownerId);
});

final hostelsFutureProvider = FutureProvider<List<HostelModel>>((ref) {
  final service = ref.read(hostelServiceProvider);
  return service.getAllHostels();
});

// final hostelByIdProvider = StreamProvider.family<HostelModel?, String>((ref, hostelId) {
//   final service = ref.read(hostelServiceProvider);
//   return service.getHostelByIdStream(hostelId);
// });

// Update this provider to use your actual service method
final hostelByIdProvider = FutureProvider.autoDispose.family<HostelModel?, String>((ref, hostelId) async {
  final service = ref.read(hostelServiceProvider);
  return await service.getHostelById(hostelId);
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



final filteredHostelsProvider = Provider.autoDispose<List<HostelModel>>((ref) {
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

  // Group rooms by hostelId once (O(m)) instead of re-scanning the full
  // rooms list inside the per-hostel filter below (which was O(n*m)).
  final roomsByHostelId = <String, List<RoomModel>>{};
  for (final room in rooms) {
    roomsByHostelId.putIfAbsent(room.hostelId, () => []).add(room);
  }

  final normalizedQuery = (filter.searchQuery != null && filter.searchQuery!.isNotEmpty)
      ? filter.searchQuery!.toLowerCase()
      : null;
  final normalizedCampus =
      (filter.campus != null && filter.campus!.isNotEmpty) ? filter.campus!.toLowerCase() : null;

  // Filter hostels
  var filteredHostels = hostels.where((hostel) {
    // Search query filter
    if (normalizedQuery != null) {
      final matchesSearch = hostel.name.toLowerCase().contains(normalizedQuery) ||
          hostel.description.toLowerCase().contains(normalizedQuery) ||
          hostel.location.toLowerCase().contains(normalizedQuery) ||
          hostel.campus.toLowerCase().contains(normalizedQuery);
      if (!matchesSearch) return false;
    }

    // Get all rooms for this hostel
    final hostelRooms = roomsByHostelId[hostel.id] ?? const [];

    // If no rooms found for this hostel, skip it
    if (hostelRooms.isEmpty) return false;

    // HOSTEL-LEVEL FILTERS
    final campusMatch =
        normalizedCampus == null || hostel.campus.toLowerCase().contains(normalizedCampus);

    final amenitiesMatch = filter.amenities.isEmpty || 
                          filter.amenities.every(hostel.amenities.contains);

    // ROOM-LEVEL FILTERS - Only consider AVAILABLE rooms
    final hasAvailableRooms = hostelRooms.any((room) {
      if (!room.available || room.availableRooms <= 0) return false;
      
      final roomTypeMatch = filter.roomType == null || room.type == filter.roomType;
      final genderMatch = filter.gender == null || room.gender == filter.gender;
      
      // Price range filter
      final minPriceMatch = filter.minPrice == null || room.price >= filter.minPrice!;
      final maxPriceMatch = filter.maxPrice == null || room.price <= filter.maxPrice!;
      
      return roomTypeMatch && genderMatch && minPriceMatch && maxPriceMatch;
    });

    return campusMatch && amenitiesMatch && hasAvailableRooms;
  }).toList();

  // Apply sorting
  switch (filter.sortBy) {
    case SortBy.priceAsc:
      filteredHostels.sort((a, b) => a.startPrice.compareTo(b.startPrice));
      break;
    case SortBy.priceDesc:
      filteredHostels.sort((a, b) => b.startPrice.compareTo(a.startPrice));
      break;
    case SortBy.rating:
      filteredHostels.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case SortBy.popularity:
      filteredHostels.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
      break;
    case SortBy.newest:
      // Assuming hostels are already sorted by newest in the stream
      break;
  }

  return filteredHostels;
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