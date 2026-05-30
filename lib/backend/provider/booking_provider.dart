
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/backend/service/storage_service.dart';

// Providers
final bookingServiceProvider = Provider<BookingService>((ref) => BookingService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

// Bookings by user
final userBookingsProvider = StreamProvider.autoDispose.family<List<BookingModel>, String>((ref, userId) {
  final service = ref.watch(bookingServiceProvider);
  return service.getBookingsByUser(userId);
});

// Bookings by owner
final ownerBookingsProvider = StreamProvider.autoDispose.family<List<BookingModel>, String>((ref, ownerId) {
  final service = ref.watch(bookingServiceProvider);
  return service.getBookingsByOwner(ownerId);
});

// Pending bookings count for owner
final pendingBookingsCountProvider = StreamProvider.autoDispose.family<int, String>((ref, ownerId) {
  final service = ref.watch(bookingServiceProvider);
  return service.getPendingBookingsCount(ownerId);
});

// Booking creation state
final bookingCreationProvider = StateNotifierProvider<BookingCreationNotifier, AsyncValue<String>>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return BookingCreationNotifier(bookingService, storageService);
});

// Booking creation notifier
class BookingCreationNotifier extends StateNotifier<AsyncValue<String>> {
  final BookingService _bookingService;
  final StorageService _storageService;

  BookingCreationNotifier(this._bookingService, this._storageService)
      : super(const AsyncValue.data(''));

  // Create booking with payment screenshot
  Future<void> createBookingWithPayment({
    required BookingModel booking,
    required XFile paymentScreenshot,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // 1. Upload payment screenshot to Firebase Storage
      final imageUrl = await _storageService.uploadPaymentScreenshot(
        paymentScreenshot, 
        booking.id,
      );

      // 2. Update booking with image URL
      final updatedBooking = BookingModel(
        id: booking.id,
        hostelId: booking.hostelId,
        hostelName: booking.hostelName,
        userId: booking.userId,
        ownerId: booking.ownerId,
        userName: booking.userName,
        userEmail: booking.userEmail,
        userPhone: booking.userPhone,
        roomId: booking.roomId,
        roomType: booking.roomType,
        checkInDate: booking.checkInDate,
        confirmationImage: imageUrl, // Use the uploaded image URL
        totalPrice: booking.totalPrice,
        status: booking.status,
        createdAt: booking.createdAt,
        specialRequests: booking.specialRequests,
      );

      // 3. Create booking in Firestore
      final bookingId = await _bookingService.createBooking(updatedBooking);
      
      state = AsyncValue.data(bookingId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  
  // Reset state
  void reset() {
    state = const AsyncValue.data('');
  }
}