import 'dart:html' as html; // For web file access
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/backend/provider/booking_provider.dart';
import 'package:my_hostel_app/backend/provider/g_provider.dart';
import 'package:my_hostel_app/ui/booking/widgets/booking_summary.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';
import 'package:my_hostel_app/backend/model/booking_model.dart';

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
  html.File? _paymentScreenshot;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _imageUrl; // For web, we'll use the file URL

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        // For web, we need to convert XFile to html.File and get URL
        final bytes = await image.readAsBytes();
        final blob = html.Blob([bytes]);
        final file = html.File([blob], image.name);
        
        setState(() {
          _paymentScreenshot = file;
          _imageUrl = html.Url.createObjectUrl(file);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        // For web, we need to convert XFile to html.File and get URL
        final bytes = await image.readAsBytes();
        final blob = html.Blob([bytes]);
        final file = html.File([blob], image.name);
        
        setState(() {
          _paymentScreenshot = file;
          _imageUrl = html.Url.createObjectUrl(file);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take photo: $e')),
        );
      }
    }
  }


Future<void> _submitPayment() async {
  if (_paymentScreenshot == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please upload payment screenshot')),
    );
    return;
  }

  // Use the guaranteed user provider
  final userAsync = ref.watch(guaranteedUserProvider);
  
  if (userAsync.isLoading) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loading user information...')),
    );
    return;
  }

  final currentUser = userAsync.value;
  
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please log in to complete booking'),
        action: SnackBarAction(
          label: 'Login',
          onPressed: () {
            final bookingUrl = '/booking/${widget.hostel.id}/${widget.room.id}';
            final encodedUrl = Uri.encodeComponent(bookingUrl);
            context.push('/login?redirect=$encodedUrl');
          },
        ),
      ),
    );
    return;
  }

  setState(() => _isUploading = true);

  try {
    // Parse check-in date from form data
    final checkInDate = _parseCheckInDate(widget.formData['checkInDate']!);
    
    // Generate a temporary ID (Firestore will generate the real one)
    final temporaryId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    

    // Create booking model with "pending" status
    final booking = BookingModel(
      id: temporaryId,
      hostelId: widget.hostel.id,
      hostelName: widget.hostel.name,
      userId: currentUser.id,
      ownerId: widget.hostel.ownerId,
      userName: widget.formData['fullName']!,
      userEmail: widget.formData['email']!,
      userPhone: widget.formData['phone']!,
      roomId: widget.room.id,
      roomType: widget.room.type,
      checkInDate: checkInDate,
      confirmationImage: '', // Will be set after upload
      totalPrice: widget.room.price,
      status: 'pending',
      createdAt: DateTime.now(),
      specialRequests: widget.formData['specialRequests'],
    );

    // Create booking using the provider
    final bookingCreation = ref.read(bookingCreationProvider.notifier);
    await bookingCreation.createBookingWithPayment(
      booking: booking,
      paymentScreenshot: _paymentScreenshot!,
    );

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Move to confirmation step
      widget.onNextStep();
    }
    
  } catch (e) {
    
    String errorMessage = 'Failed to submit booking';
    if (e.toString().contains('permission-denied')) {
      errorMessage = 'Firestore permission denied. Check your security rules.';
    } else if (e.toString().contains('storage')) {
      errorMessage = 'Failed to upload payment screenshot.';
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() => _isUploading = false);
  }
}


DateTime _parseCheckInDate(String dateString) {
  // Parse date from "dd/MM/yyyy" format
  final parts = dateString.split('/');
  if (parts.length == 3) {
    return DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
  }
  // Fallback to current date if parsing fails
  return DateTime.now();
}

  @override
  void dispose() {
    // Clean up object URL to prevent memory leaks
    if (_imageUrl != null) {
      html.Url.revokeObjectUrl(_imageUrl!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Instructions Section
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BigText(text: "Payment Instructions", color:theme.colorScheme.onSurface, size: 18.sp),
                SizedBox(height: 10.h),
                SmallText(
                  text: "Please make payment and upload screenshot for verification",
                  color: Colors.blueGrey,
                ),
                SizedBox(height: 30.h),

                // Payment Details Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BigText(
                        text: "Make Payment via Mobile Money",
                        color: Colors.blue.shade900,
                        size: 16.sp,
                      ),
                      SizedBox(height: 16.h),
                      _buildPaymentDetail("Provider", "MTN Mobile Money"),
                      _buildPaymentDetail("Phone Number", "055 123 4567"),
                      _buildPaymentDetail("Account Name", "HostelHub Ghana"),
                      _buildPaymentDetail("Reference", "Your Name + Room Booking"),
                      _buildPaymentDetail(
                        "Amount", 
                        "GHS ${widget.room.price.toStringAsFixed(2)}",
                        isBold: true,
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange, size: 16.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: SmallText(
                                text: "Use your name as reference for easy verification",
                                color: Colors.orange.shade800,
                                size: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // Screenshot Upload Section
                BigText(text: "Upload Payment Proof", color: theme.colorScheme.onSurface, size: 16.sp),
                SizedBox(height: 16.h),
                SmallText(
                  text: "Upload a clear screenshot of your payment confirmation",
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                SizedBox(height: 20.h),

                // Image Preview and Upload Buttons
                if (_imageUrl != null) ...[
                  Container(
                    height: 200.h,
                    width: 400.6.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: theme.shadowColor.withOpacity(0.08)),
                    ),
                    child: EnhancedCachedImage(
                      imageUrl: _imageUrl!,
                      height: 200.h,
                      width: 400.6.w,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12.r),
                      showShimmer: false,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: Icon(Icons.camera_alt, size: 16.sp),
                        label: Text('Take Photo', style: TextStyle(fontSize: 12.sp)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.photo_library, size: 16.sp),
                        label: Text('Choose from Gallery', style: TextStyle(fontSize: 12.sp)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: TextButton(
                      onPressed: _pickImage,
                      child: Text(
                        'Change Image',
                        style: TextStyle(color: Colors.blue, fontSize: 12.sp),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    height: 200.h,
                    width: 400.6.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 40.sp, color: Colors.grey.shade400),
                        SizedBox(height: 8.h),
                        SmallText(text: "No screenshot uploaded", color: Colors.grey.shade600),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: Icon(Icons.camera_alt, size: 16.sp),
                              label: Text('Take Photo', style: TextStyle(fontSize: 12.sp)),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.photo_library, size: 16.sp),
                              label: Text('Choose from Gallery', style: TextStyle(fontSize: 12.sp)),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 40.h),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElvButtonWidget(
                      text: "Back",
                      isPrimary: false,
                      onPressed: widget.onPreviousStep,
                    ),
                    ElvButtonWidget(
                      text: _isUploading ? "Processing..." : "Submit Payment",
                      isPrimary: _paymentScreenshot != null && !_isUploading,
                      onPressed: _isUploading ? null : _submitPayment,
                    ),
                  ],
                ),

                // Debug info (remove in production)
                if (_paymentScreenshot != null) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: SmallText(
                      text: "Screenshot ready: ${_paymentScreenshot!.name}",
                      color: Colors.green.shade800,
                      size: 10.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        SizedBox(width: 50.w),

        // Summary Section
        Expanded(
          flex: 1,
          child: BookingSummaryCard(hostel: widget.hostel, room: widget.room),
        ),
      ],
    );
  }

  Widget _buildPaymentDetail(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(text: title, color: Colors.blueGrey),
          SmallText(
            text: value,
            color: isBold ? Colors.blue : Colors.black,
            size: isBold ? 12.sp : 10.sp,
          ),
        ],
      ),
    );
  }
}