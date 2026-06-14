import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/provider/booking_provider.dart';
import 'package:my_hostel_app/backend/provider/g_provider.dart';
import 'package:my_hostel_app/backend/service/paystack_service.dart';
import 'package:my_hostel_app/backend/service/paystack_web.dart' as paystack_web;
import 'package:my_hostel_app/ui/booking/widgets/booking_summary.dart';
import 'package:my_hostel_app/ui/booking/widgets/paystack_webview_screen.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class PaymentStep extends ConsumerStatefulWidget {
  final HostelModel hostel;
  final RoomModel room;
  final Map<String, String> formData;
  final VoidCallback onNextStep;
  final VoidCallback onPreviousStep;

  const PaymentStep({
    super.key,
    required this.hostel,
    required this.room,
    required this.formData,
    required this.onNextStep,
    required this.onPreviousStep,
  });

  @override
  ConsumerState<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends ConsumerState<PaymentStep> {
  bool _isProcessing = false;
  final _paystackService = PaystackService();

  DateTime _parseCheckInDate(String dateString) {
    final parts = dateString.split('/');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
    return DateTime.now();
  }

  Future<void> _pay() async {
    setState(() => _isProcessing = true);

    // Await the FutureProvider's actual resolved value, not a loading snapshot
    final currentUser = await ref.read(guaranteedUserProvider.future);

    if (!mounted) return;

    if (currentUser == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('Please log in to complete booking'),
            action: SnackBarAction(
              label: 'Login',
              onPressed: () {
                final url = '/booking/${widget.hostel.id}/${widget.room.id}';
                context.push('/login?redirect=${Uri.encodeComponent(url)}');
              },
            ),
          ),
        );
      setState(() => _isProcessing = false);
      return;
    }

    try {
      final reference = _paystackService.generateReference();
      String? result;

      if (kIsWeb) {
        // Web: open Paystack's inline popup via dart:html + window.postMessage
        result = await paystack_web.processPaystackWebPayment(
          publicKey: PaystackService.publicKey,
          email: widget.formData['email']!,
          amountInPesewas: (widget.room.price * 100).toInt(),
          reference: reference,
          customerName: widget.formData['fullName']!,
        );
      } else {
        // Mobile: show Paystack inline in a WebView screen
        final html = _paystackService.buildPaymentHtml(
          amountInGHS: widget.room.price,
          email: widget.formData['email']!,
          customerName: widget.formData['fullName']!,
          reference: reference,
        );
        result = await Navigator.of(context).push<String?>(
          MaterialPageRoute(
            builder: (_) => PaystackWebViewScreen(html: html),
            fullscreenDialog: true,
          ),
        );
      }

      if (!mounted) return;
      if (result == null) return; // user cancelled

      final booking = BookingModel(
        id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
        hostelId: widget.hostel.id,
        hostelName: widget.hostel.name,
        userId: currentUser.id,
        ownerId: widget.hostel.ownerId,
        userName: widget.formData['fullName']!,
        userEmail: widget.formData['email']!,
        userPhone: widget.formData['phone']!,
        roomId: widget.room.id,
        roomType: widget.room.type,
        checkInDate: _parseCheckInDate(widget.formData['checkInDate']!),
        totalPrice: widget.room.price,
        status: 'confirmed',
        createdAt: DateTime.now(),
        specialRequests: widget.formData['specialRequests'],
      );

      await ref.read(bookingCreationProvider.notifier).createBookingWithPaystack(
        booking: booking,
        paymentReference: result,
      );

      if (mounted) widget.onNextStep();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('Failed to complete booking: $e'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = widget.room.price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BigText(
                  text: 'Complete Payment',
                  color: theme.colorScheme.onSurface,
                  size: 18.sp,
                ),
                SizedBox(height: 6.h),
                SmallText(
                  text: 'Your payment is securely processed by Paystack',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: 30.h),

                // Order summary
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmallText(
                        text: 'Order Summary',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 11.sp,
                      ),
                      SizedBox(height: 12.h),
                      _summaryRow(theme, 'Hostel', widget.hostel.name),
                      _summaryRow(theme, 'Room', widget.room.type),
                      _summaryRow(theme, 'Check-in', widget.formData['checkInDate'] ?? '—'),
                      _summaryRow(theme, 'Student', widget.formData['fullName'] ?? '—'),
                      Divider(height: 24.h, color: theme.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BigText(
                            text: 'Total',
                            color: theme.colorScheme.onSurface,
                            size: 14.sp,
                          ),
                          BigText(
                            text: 'GHS ${amount.toStringAsFixed(2)}',
                            color: theme.colorScheme.primary,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Payment features
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      _featureRow(theme, Icons.lock_outline, 'Secured by Paystack'),
                      SizedBox(height: 10.h),
                      _featureRow(theme, Icons.phone_android, 'MTN MoMo · Vodafone Cash · AirtelTigo'),
                      SizedBox(height: 10.h),
                      _featureRow(theme, Icons.credit_card, 'Visa · Mastercard · Bank transfer'),
                      SizedBox(height: 10.h),
                      _featureRow(theme, Icons.check_circle_outline, 'Instant booking confirmation'),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElvButtonWidget(
                      text: 'Back',
                      isPrimary: false,
                      onPressed: _isProcessing ? null : widget.onPreviousStep,
                    ),
                    _isProcessing
                        ? const CircularProgressIndicator()
                        : FilledButton.icon(
                            onPressed: _pay,
                            icon: Icon(Icons.payment, size: 18.sp),
                            label: Text(
                              'Pay GHS ${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 14.h,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 50.w),

        Expanded(
          flex: 1,
          child: BookingSummaryCard(hostel: widget.hostel, room: widget.room),
        ),
      ],
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(text: label, color: theme.colorScheme.onSurfaceVariant, size: 12.sp),
          Flexible(
            child: SmallText(text: value, color: theme.colorScheme.onSurface, size: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: theme.colorScheme.primary),
        SizedBox(width: 10.w),
        Flexible(
          child: SmallText(text: text, color: theme.colorScheme.onSurface, size: 12.sp),
        ),
      ],
    );
  }
}
