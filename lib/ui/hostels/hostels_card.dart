import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

class HostelCard extends StatefulWidget {
  final HostelModel hostel;

  const HostelCard({super.key, required this.hostel});

  @override
  State<HostelCard> createState() => _HostelCardState();
}

class _HostelCardState extends State<HostelCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HapticGestureDetector(
      onTap: () {
        context.push('/hostel-details', extra: widget.hostel);
      },
      feedbackType: HapticFeedbackType.light,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        alignment: Alignment.topCenter,
        width: 0.25.sw,

        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _isHovered ? theme.colorScheme.primary.withOpacity(0.4) : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? theme.colorScheme.primary.withOpacity(0.12)
                  : theme.shadowColor.withOpacity(0.08),
              blurRadius: _isHovered ? 18 : 8,
              spreadRadius: _isHovered ? 4 : 2,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            //Image + Price Tag
            Stack(
              children: [
                widget.hostel.images.isNotEmpty
                    ? EnhancedCachedImage(
                        imageUrl: widget.hostel.images.first,
                        height: 300.h,
                        width: 0.25.sw,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                        showShimmer: true,
                      )
                    : Container(
                        height: 300.h,
                        width: 0.25.sw,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64.w,
                          color: Colors.grey[600],
                        ),
                      ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: SmallContainerAndText(
                    containerColor: theme.colorScheme.surface,
                    text:
                        "From GHS ${widget.hostel.startPrice.toStringAsFixed(0)}/semester",
                    textColor: theme.colorScheme.onSurface,
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
                          text: widget.hostel.name,
                          color: theme.colorScheme.onSurface,
                          size: 13.sp,
                          overFlow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconAndTextWidget(
                            icon: Icons.star,
                            text: widget.hostel.rating.toStringAsFixed(1),
                            iconColor: theme.colorScheme.tertiary,
                          ),
                          SizedBox(width: 5.w),
                          SmallText(
                            text: "(${widget.hostel.reviewsCount})",
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
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
                    text: "${widget.hostel.campus} - ${widget.hostel.location}",
                    iconColor: theme.colorScheme.primary,
                    textSize: 10.sp,
                  ),

                  SizedBox(height: 15.h),

                  /// Description
                  SmallText(
                    text: widget.hostel.description,
                    size: 11.sp,
                    overFlow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 15.h),

                  /// Amenities
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      // Show first 3 amenities
                      ...widget.hostel.amenities
                          .take(3)
                          .map(
                            (amenity) => SmallContainerAndText(
                                containerColor: theme.colorScheme.primary.withOpacity(0.06),
                              text: amenity,
                                textColor: theme.colorScheme.onSurface,
                              textSize: 9.sp,
                            ),
                          ),
                      // Add "+more" if there are more than 3 amenities
                      if (widget.hostel.amenities.length > 3)
                        SmallContainerAndText(
                          containerColor: theme.colorScheme.primary.withOpacity(0.06),
                          text: "+${widget.hostel.amenities.length - 3} more",
                          textColor: theme.colorScheme.onSurface,
                          textSize: 9.sp,
                        ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  /// View Details Button
                  GestureDetector(
                    onTap: () {
                      // Using GoRouter navigation
                      GoRouter.of(
                        context,
                      ).go('/hostel-details/${widget.hostel.id}');
                    },

                    child: Container(
                      height: 0.04.sh,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: theme.colorScheme.primary,
                      ),
                      child: Center(
                        child: Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SmallText(text: text, size: textSize, color: textColor),
    );
  }
}
