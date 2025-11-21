// import 'dart:io';

// import 'package:cross_file/src/types/interface.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:my_hostel_app/backend/model/hostel_model.dart';
// import 'package:my_hostel_app/backend/service/owner_hostel_service.dart';
              

// // HostelService Provider
// final hostelServiceProvider = Provider<HostelService>((ref) {
//   return HostelService();
// });

// // Hostels Stream Provider
// final hostelsStreamProvider = StreamProvider<List<HostelModel>>((ref) {
//   final hostelService = ref.watch(hostelServiceProvider);
//   return hostelService.getMyHostels();
// });

// // Hostel Notifier State
// class HostelState {
//   final bool isLoading;
//   final String? error;
//   final List<HostelModel> hostels;

//   HostelState({
//     this.isLoading = false,
//     this.error,
//     this.hostels = const [],
//   });

//   HostelState copyWith({
//     bool? isLoading,
//     String? error,
//     List<HostelModel>? hostels,
//   }) {
//     return HostelState(
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       hostels: hostels ?? this.hostels,
//     );
//   }
// }

// // Hostel Notifier
// class HostelNotifier extends StateNotifier<HostelState> {
//   final HostelService _hostelService;

//   HostelNotifier(this._hostelService) : super(HostelState());

//   // Load hostels (if you need manual refresh)
//   Future<void> loadHostels() async {
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       // For manual refresh, you might want to use a FutureProvider instead
//       // This is useful if you're not using the stream directly
//       state = state.copyWith(isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//  // Add this method to your HostelNotifier in hostel_provider.dart
// Future<bool> addHostelWithImages(HostelModel hostel, List<File> imageFiles) async {
//   state = state.copyWith(isLoading: true, error: null);
  
//   try {
//     await _hostelService.addHostelWithImages(hostel, imageFiles.cast<XFile>());
//     state = state.copyWith(isLoading: false);
//     return true;
//   } catch (e) {
//     state = state.copyWith(isLoading: false, error: e.toString());
//     return false;
//   }
// }

//   // Update hostel
//   Future<bool> updateHostel(String hostelId, HostelModel hostel) async {
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       await _hostelService.updateHostel(hostelId, hostel);
//       state = state.copyWith(isLoading: false);
//       return true;
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//       return false;
//     }
//   }

//   // Delete hostel
//   Future<bool> deleteHostel(String hostelId) async {
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       await _hostelService.deleteHostel(hostelId);
//       state = state.copyWith(isLoading: false);
//       return true;
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//       return false;
//     }
//   }

//   // Update hostel status
//   Future<bool> updateHostelStatus(String hostelId, String status) async {
//     try {
//       await _hostelService.updateHostelStatus(hostelId, status);
//       return true;
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//       return false;
//     }
//   }

//   // Clear error
//   void clearError() {
//     state = state.copyWith(error: null);
//   }
// }

// // Hostel Notifier Provider
// final hostelNotifierProvider = StateNotifierProvider<HostelNotifier, HostelState>((ref) {
//   final hostelService = ref.watch(hostelServiceProvider);
//   return HostelNotifier(hostelService);
// });