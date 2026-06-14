import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/service/booking_service.dart';
import 'package:my_hostel_app/backend/service/notification_helper.dart';
import 'package:my_hostel_app/backend/service/paystack_service.dart';
import 'package:my_hostel_app/backend/service/storage_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) => BookingService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final paystackServiceProvider = Provider<PaystackService>((ref) => PaystackService());

final userBookingsProvider = StreamProvider.autoDispose.family<List<BookingModel>, String>((ref, userId) {
  final service = ref.watch(bookingServiceProvider);
  return service.getBookingsByUser(userId);
});

final ownerBookingsProvider = StreamProvider.autoDispose.family<List<BookingModel>, String>((ref, ownerId) {
  final service = ref.watch(bookingServiceProvider);
  return service.getBookingsByOwner(ownerId);
});

final pendingBookingsCountProvider = StreamProvider.autoDispose.family<int, String>((ref, ownerId) {
  final service = ref.watch(bookingServiceProvider);
  return service.getPendingBookingsCount(ownerId);
});

final bookingCreationProvider = StateNotifierProvider<BookingCreationNotifier, AsyncValue<String>>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  return BookingCreationNotifier(bookingService);
});

class BookingCreationNotifier extends StateNotifier<AsyncValue<String>> {
  final BookingService _bookingService;

  BookingCreationNotifier(this._bookingService) : super(const AsyncValue.data(''));

  Future<String> createBookingWithPaystack({
    required BookingModel booking,
    required String paymentReference,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Transaction: create confirmed booking + decrement room inventory atomically.
      final bookingId = await _bookingService.createConfirmedBookingWithInventory(
        booking: booking,
        paymentReference: paymentReference,
      );
      state = AsyncValue.data(bookingId);

      // Fire notifications in parallel — non-blocking for the caller.
      NotificationHelper.sendBookingConfirmationToStudent(
        userId: booking.userId,
        hostelName: booking.hostelName,
        bookingId: bookingId,
      );
      NotificationHelper.sendPaymentConfirmation(
        userId: booking.userId,
        amount: booking.totalPrice,
        bookingId: bookingId,
      );
      NotificationHelper.sendNewBookingToOwner(
        ownerId: booking.ownerId,
        studentName: booking.userName,
        hostelName: booking.hostelName,
        bookingId: bookingId,
      );

      return bookingId;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data('');
  }
}
