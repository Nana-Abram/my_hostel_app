import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class HostelCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String location;
  final double rating;
  final int reviewsCount;
  final double price;
  final String description;
  final List<String> amenities;
  final VoidCallback? onPressed;

  const HostelCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.description,
    required this.amenities,
    this.onPressed,
  });

  @override
  State<HostelCard> createState() => _HostelCardState();
}

class _HostelCardState extends State<HostelCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        width: 0.25.sw,
        height:0.60.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          // border: Border.all(color: Colors.grey.shade300, width: 0.8),
           border: Border.all(
            color: _isHovered ? Colors.blueGrey : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? Colors.blueGrey.shade50
                  : Colors.grey.shade300,
              blurRadius: _isHovered ? 18 : 8,
              spreadRadius: _isHovered ? 4: 2,
              offset: const Offset(2, 2),
            ),
            
          ],
        ),
        child: Column(
          children: [
            //Image + Price Tag
            Stack(
              children: [
                Container(
                  height: 0.28.sh,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(widget.imageUrl),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: SmallContainerAndText(
                    containerColor: Colors.white,
                    text:
                        "From GHS ${widget.price.toStringAsFixed(0)}/semester",
                    textColor: Colors.black,
                    textSize: 9.sp,
                  ),
                ),
              ],
            ),

            // Details Section
            Container(
              margin: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name + Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SmallText(
                          text: widget.name,
                          color: Colors.black,
                          size: 13.sp,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconAndTextWidget(
                            icon: Icons.star,
                            text: widget.rating.toStringAsFixed(1),
                            iconColor: Colors.orange,
                          ),
                          SizedBox(width: 5.w),
                          SmallText(
                            text: "(${widget.reviewsCount})",
                            color: Colors.black,
                            size: 11.sp,
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 15.h),

                  /// Location
                  IconAndTextWidget(
                    icon: Icons.location_on_outlined,
                    text: widget.location,
                    iconColor: Colors.blueGrey,
                    textSize: 10.sp,
                  ),

                  SizedBox(height: 15.h),

                  /// Description
                  SmallText(
                    text: widget.description,
                    size: 11.sp,
                    overFlow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 15.h),

                  /// Amenities
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: widget.amenities
                        .take(5)
                        .map(
                          (amenity) => SmallContainerAndText(
                            containerColor: Colors.blueGrey.shade50,
                            text: amenity,
                            textColor: Colors.black,
                            textSize: 9.sp,
                          ),
                        )
                        .toList(),
                  ),

                  SizedBox(height: 20.h),

                  /// View Details Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.hostelDetails);
                    },
                    child: Container(
                      height: 0.04.sh,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: AppColors.blueColor,
                      ),
                      child: Center(
                        child: Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Reusable Chip-like Label
class SmallContainerAndText extends StatelessWidget {
  final Color containerColor;
  final String text;
  final Color textColor;
  final double textSize;

  const SmallContainerAndText({
    super.key,
    required this.containerColor,
    required this.text,
    required this.textColor,
    this.textSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SmallText(
        text: text,
        size: textSize,
        color: textColor,
      ),
    );
  }
}
