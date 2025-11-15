import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/hostels/filter_section.dart';
import 'package:my_hostel_app/ui/hostels/hostel_grid.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class HostelsScreen extends StatelessWidget {
  const HostelsScreen({super.key});

  @override
  Widget build(BuildContext context) {

     WidgetsBinding.instance.addPostFrameCallback((_) {
      // You might want to be more selective about when to clear
      // ref.read(filterProvider.notifier).clearFilters();
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: EdgeInsets.only(top: 40.h, left: 80.w, right: 40.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- HEADER TEXTS ---
            SizedBox(height: 10.h),
            BigText(text: "Available Hostels", size: 18.sp),
            SizedBox(height: 10.h),
            SmallText(text: "Found 6 hostels matching your criteria"),
            SizedBox(height: 20.h),
        
            /// --- MAIN SECTION ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// FILTER SIDEBAR (LEFT)
                  const FilterSection(),
              
                  SizedBox(width: 40.w),
              
                 
                  Expanded(
                    child: SingleChildScrollView(child: Column(
                      children: [
                        const HostelGrid(),
                      ],
                    )),
                  ),
                ],
              ),
            ),
        
            // SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}
