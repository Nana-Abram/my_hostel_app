import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class BookingSummaryCard extends StatelessWidget {
  final HostelModel hostel;
  final RoomModel room;

  const BookingSummaryCard({
    super.key,
    required this.hostel,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomImage = room.image.isNotEmpty
        ? room.image
        : (hostel.images.isNotEmpty ? hostel.images.first : '');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room image
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            child: roomImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) => ImageNetwork(
                        image: roomImage,
                        height: 200.h,
                        width: constraints.maxWidth,
                        fitAndroidIos: BoxFit.cover,
                        fitWeb: BoxFitWeb.cover,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.hotel,
                      size: 60.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
          ),

          // Booking details
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BigText(
                  text: "Booking Summary",
                  color: theme.colorScheme.onSurface,
                  size: 16.sp,
                ),
                SizedBox(height: 20.h),

                _buildSummaryRow(
                  theme,
                  "Hostel", hostel.name),
                _buildSummaryRow(theme, "Room Type", room.type),
                _buildSummaryRow(theme, "Campus", hostel.campus),
                _buildSummaryRow(theme, "Duration", "One semester"),
                _buildSummaryRow(
                  theme,
                  "Price",
                  "GHS ${room.price.toStringAsFixed(2)}",
                ),
                const Divider(),
                _buildSummaryRow(
                  theme,
                  "Total",
                  "GHS ${room.price.toStringAsFixed(2)}",
                  isBold: true,
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String title, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(text: title, color: Colors.blueGrey),
          SmallText(
            text: value,
            color: isBold ? Colors.blue :theme.colorScheme.onSurface,
            size: isBold ? 12.sp : 10.sp,
          ),
        ],
      ),
    );
  }
}