import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

class HostelImageCarousel extends StatelessWidget {
  final List<String> images;

  const HostelImageCarousel({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    if (isMobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return EnhancedImageCarousel(
            images: images,
            height: 220.0,
            width: constraints.maxWidth,
            showIndicators: true,
            showArrows: false,
            borderRadius: BorderRadius.circular(16.r),
          );
        },
      );
    }
    return EnhancedImageCarousel(
      images: images,
      height: 400.h,
      width: 0.95.sw,
      showIndicators: true,
      showArrows: true,
      borderRadius: BorderRadius.circular(16.r),
    );
  }
}
