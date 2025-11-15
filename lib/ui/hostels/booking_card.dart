import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class BookingCardWidget extends StatefulWidget {
  final HostelModel hostel;

  const BookingCardWidget({super.key, required this.hostel});

  @override
  State<BookingCardWidget> createState() => _BookingCardWidgetState();
}

class _BookingCardWidgetState extends State<BookingCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;
  late Animation<double> _glow;
  late Animation<double> _fade;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounce = Tween<double>(begin: 0, end: 8.h)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    _glow = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    _fade = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostel = widget.hostel;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 0.25.sw,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // Colors.amber.withOpacity(0.05),
              AppColors.blueColor.withOpacity(0.05),
              Colors.white,
              AppColors.blueColor.withOpacity(0.05),
              // Colors.amber.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.blueColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
            if (_isHovered)
              BoxShadow(
                color: AppColors.blueColor.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -20.h,
              right: -20.h,
              child: AnimatedBuilder(
                animation: _glow,
                builder: (context, child) {
                  return Container(
                    width: 80.h,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.blueColor.withOpacity(_glow.value * 0.3),
                          AppColors.blueColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.blueColor,
                            AppColors.blueColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.hotel_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: BigText(
                        text: "Ready to Move In?",
                        color: AppColors.blueColor,
                        size: 16.sp,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // Description with fade animation
                AnimatedBuilder(
                  animation: _fade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fade.value,
                      child: SmallText(
                        text: "Discover your perfect home at ${hostel.name}. "
                            "Experience premium amenities, security, and just "
                            "minutes away from ${hostel.campus} campus.",
                        color: Colors.black87,
                        size: 11.sp,
                        
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 20.h),
                
                // Stats row
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.star_rounded,
                        "${hostel.rating}",
                        "Rating",
                        AppColors.orangeColor,
                      ),
                      Container(
                        width: 1,
                        height: 30.h,
                        color: Colors.grey.shade300,
                      ),
                      _buildStatItem(
                        Icons.attach_money_rounded,
                        "GHS ${hostel.startPrice}",
                        "Starting Price",
                        Colors.green,
                      ),
                      Container(
                        width: 1,
                        height: 30.h,
                        color: Colors.grey.shade300,
                      ),
                      _buildStatItem(
                        Icons.location_pin,
                        hostel.campus.split(' ').first,
                        "Campus",
                        AppColors.blueColor,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Animated CTA section
                AnimatedBuilder(
                  animation: _bounce,
                  builder: (context, child) {
                    return Column(
                      children: [
                        Transform.translate(
                          offset: Offset(0, _bounce.value),
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.blueColor,
                                  AppColors.blueColor.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blueColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_downward_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Explore Available Rooms",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Scroll down to discover your future home",
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}