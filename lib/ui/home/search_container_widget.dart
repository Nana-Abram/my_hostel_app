import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/widgets/dropdown_button_widet.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class SearchContainer extends StatelessWidget {
  const SearchContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Center(
          child: Container(
            width: isMobile ? 0.9.sw : 0.45.sw,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      DropdownButtonWidget(
                        icon: Icons.location_on_outlined,
                        label: "Campus",
                        hint: "Select campus",
                        items: [
                          'UENR Sunyani campus',
                          'UENR Dormaa campus',
                          'KSTU Sunyani campus'
                        ],
                      ),
                      SizedBox(height: 5.h),
                      DropdownButtonWidget(
                        icon: Icons.people_outline,
                        label: "People per room",
                        hint: "Select rooms",
                        items: [
                          "Single",
                          "Two in a room",
                          "Three in a room",
                          "Four in a room"
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _buildSearchButton(isMobile),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: DropdownButtonWidget(
                          icon: Icons.location_on_outlined,
                          label: "Campus",
                          hint: "Select campus",
                          items: [
                            'UENR Sunyani campus',
                            'UENR Dormaa campus',
                            'KSTU Sunyani campus'
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: DropdownButtonWidget(
                          icon: Icons.people_outline,
                          label: "People per room",
                          hint: "Select rooms",
                          items: [
                            "Single",
                            "Two in a room",
                            "Three in a room",
                            "Four in a room"
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _buildSearchButton(isMobile),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(bool isMobile) {
    return Container(
      margin: EdgeInsets.only(top: isMobile ? 20.h : 40.h),
      width: 120.w,
      height: 55.h,
      decoration: BoxDecoration(
        color: AppColors.blueColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, color: Colors.white, size: 24.r),
          SizedBox(width: 5.w),
          SmallText(text: "Search", color: Colors.white),
        ],
      ),
    );
  }
}
