import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/widgets/avatar_and_text_wiget.dart';

class BookingProgressIndicator extends StatelessWidget {
  final int currentStep;
  
  const BookingProgressIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = ["Details", "Payment", "Confirmation"];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index <= currentStep - 1;
          final isLast = index == steps.length - 1;

          return AvatarAndTextWiget(
            circleText: "${index + 1}",
            color: isActive ? AppColors.blueColor : Colors.blueGrey.shade400,
            firstText: step,
            secondText: "",
            avatarRadius: 25,
            isBold: isActive,
            needsDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }
}