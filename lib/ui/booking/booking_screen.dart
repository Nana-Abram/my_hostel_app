import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/room_provider.dart';
import 'package:my_hostel_app/ui/booking/widgets/booking_appbar.dart';
import 'package:my_hostel_app/ui/booking/widgets/details_steps.dart';
import 'package:my_hostel_app/ui/booking/widgets/progress_indicator.dart';
import 'package:my_hostel_app/ui/booking/widgets/payment_step.dart';
import 'package:my_hostel_app/ui/booking/widgets/confirmation_step.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String hostelId;

  const BookingScreen({
    super.key,
    required this.hostelId,
    required this.roomId,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _currentStep = 1;

  // Form data that will be shared across steps
  final Map<String, String> _formData = {};

  void _goToNextStep() {
    setState(() {
      if (_currentStep < 3) _currentStep++;
    });
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
    });
  }

  void _updateFormData(String key, String value) {
    _formData[key] = value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hostelAsync = ref.watch(hostelByIdProvider(widget.hostelId));
    final roomAsync = ref.watch(roomByIdProvider(widget.roomId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: BookingAppBar(),
      body: hostelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState("Failed to load hostel"),
        data: (hostel) => roomAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorState("Failed to load room"),
          data: (room) {
            if (hostel == null || room == null) {
              return _buildErrorState("Hostel or room not found");
            }
            return _buildBookingContent(hostel, room);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50.sp),
          SizedBox(height: 16.h),
          Text(message, style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text("Go Back"),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingContent(HostelModel hostel, RoomModel room) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Back button
          Padding(
            padding: EdgeInsets.only(top: 20.h, left: 20.w),
            child: GestureDetector(
              onTap: () {
                if (_currentStep > 1) {
                  _goToPreviousStep();
                } else {
                  context.pop();
                }
              },
              child: const IconAndTextWidget(
                icon: Icons.arrow_back_ios,
                text: 'Back',
                iconColor: Colors.blueGrey,
                isBackArrow: true,
              ),
            ),
          ),

          // Progress indicator
          BookingProgressIndicator(currentStep: _currentStep),

          // Current step content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 40.h),
              child: _buildCurrentStep(hostel, room),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(HostelModel hostel, RoomModel room) {
    switch (_currentStep) {
      case 1:
        return DetailsStep(
          hostel: hostel,
          room: room,
          onNextStep: _goToNextStep,
          onFormDataUpdate: _updateFormData,
          initialData: _formData,
        );
      case 2:
        return PaymentStep(
          hostel: hostel,
          room: room,
          formData: _formData,
          onNextStep: _goToNextStep,
          onPreviousStep: _goToPreviousStep,
        );
      case 3:
        return ConfirmationStep(
          hostel: hostel,
          room: room,
          formData: _formData,
          onComplete: () => context.go('/'),
        );
      default:
        return DetailsStep(
          hostel: hostel,
          room: room,
          onNextStep: _goToNextStep,
          onFormDataUpdate: _updateFormData,
          initialData: _formData,
        );
    }
  }
}