import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/ui/hostels/filter_section.dart';
import 'package:my_hostel_app/ui/hostels/hostel_grid.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

class HostelsScreen extends ConsumerWidget {
  const HostelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: 40.h, left: 80.w, right: 40.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- HEADER TEXTS ---
            SizedBox(height: 10.h),
            BigText(text: "Available Hostels", size: 18.sp, color: theme.colorScheme.onSurface),
            SizedBox(height: 10.h),
            SmallText(text: "Found 6 hostels matching your criteria", color: theme.colorScheme.onSurface.withOpacity(0.7)),
            SizedBox(height: 20.h),
        
            /// --- MAIN SECTION ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// FILTER SIDEBAR (LEFT)
                  const FilterSection(),
              
                  SizedBox(width: 40.w),
              
                  /// HOSTEL GRID WITH PULL-TO-REFRESH
                  Expanded(
                    child: PullToRefreshWrapper(
                      onRefresh: () async {
                        // Refresh hostels data
                        ref.invalidate(hostelsStreamProvider);
                        // Wait a bit for the data to reload
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: const SingleChildScrollView(
                        child: Column(
                          children: [
                            HostelGrid(),
                          ],
                        ),
                      ),
                    ),
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
