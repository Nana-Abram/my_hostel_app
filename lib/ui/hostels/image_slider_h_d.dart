import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';

class HostelImageCarousel extends StatefulWidget {
  final List<String> images;

  const HostelImageCarousel({super.key, required this.images});

  @override
  State<HostelImageCarousel> createState() => _HostelImageCarouselState();
}

class _HostelImageCarouselState extends State<HostelImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _prevImage() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      setState(() {});
    }
  }

  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //IMAGE SLIDER
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SizedBox(
            height: 400.h,
            width: 0.95.sw,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (_, index) {
                return ImageNetwork(
                  image: widget.images[index], 
                  height: 400.h, 
                  width: 0.95.sw,
                  // duration: 100,
                  curve: Curves.easeIn,
                  fitAndroidIos: BoxFit.cover,
                  fitWeb: BoxFitWeb.cover,
                  );
              },
            ),
          ),
        ),

        /// LEFT ARROW
        Positioned(
          left: 20.w,
          top: 150.h,
          child: _arrowButton(
            Icons.arrow_back_ios,
            onTap: _prevImage,
            isDisabled: _currentIndex == 0,
          ),
        ),

        /// RIGHT ARROW
        Positioned(
          right: 20.w,
          top: 150.h,
          child: _arrowButton(
            Icons.arrow_forward_ios,
            onTap: _nextImage,
            isDisabled: _currentIndex == widget.images.length - 1,
          ),
        ),

        /// PAGE INDICATOR (DOTS)
        Positioned(
          bottom: 15.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              final isActive = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 20.w : 10.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.blueColor: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  /// Reusable arrow widget
  Widget _arrowButton(IconData icon,
      {required void Function()? onTap, bool isDisabled = false}) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: CircleAvatar(
        radius: 20.r,
        backgroundColor:
            isDisabled ? Colors.grey.shade200 : Colors.white.withOpacity(.85),
        child: Icon(
          icon,
          size: 18.sp,
          color: isDisabled ? Colors.grey : Colors.black,
        ),
      ),
    );
  }
}
