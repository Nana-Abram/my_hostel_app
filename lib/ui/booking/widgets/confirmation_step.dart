import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class ConfirmationStep extends StatelessWidget {
  final HostelModel hostel;
  final RoomModel room;
  final Map<String, String> formData;
  final VoidCallback onComplete;

  const ConfirmationStep({
    super.key,
    required this.hostel,
    required this.room,
    required this.formData,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 80.sp, color: Colors.green),
            SizedBox(height: 20.h),
            BigText(text: "Booking Submitted!", color: Colors.green, size: 20.sp),
            SizedBox(height: 10.h),
            SmallText(
              text: "Your booking request has been submitted for review",
              color: Colors.blueGrey,
            ),
            SizedBox(height: 30.h),

            // Booking Details
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BigText(
                    text: "Booking Details",
                    color: Colors.green.shade900,
                    size: 16.sp,
                  ),
                  SizedBox(height: 16.h),
                  _buildConfirmationDetail("Hostel", hostel.name),
                  _buildConfirmationDetail("Room Type", room.type),
                  _buildConfirmationDetail("Student Name", formData['fullName'] ?? ''),
                  _buildConfirmationDetail("Check-in Date", formData['checkInDate'] ?? ''),
                  _buildConfirmationDetail("Total Paid", "GHS ${room.price.toStringAsFixed(2)}"),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.blue, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: SmallText(
                            text: "You will receive a confirmation email within 24 hours",
                            color: Colors.blue.shade800,
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

            ElvButtonWidget(
              text: "Back to Home",
              isPrimary: true,
              onPressed: onComplete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationDetail(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(text: title, color: Colors.blueGrey),
          SmallText(text: value, color: Colors.black),
        ],
      ),
    );
  }
}