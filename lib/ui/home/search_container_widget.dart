import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/ui/app_bar/app_bar_screen.dart';

import 'package:my_hostel_app/ui/widgets/dropdown_button_widet.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';


 class SearchContainer extends ConsumerStatefulWidget {
  const SearchContainer({super.key});

  @override
  ConsumerState<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends ConsumerState<SearchContainer> {
  late TextEditingController _campusController;

  @override
  void initState() {
    super.initState();
    _campusController = TextEditingController();
    
    // Initialize with current filter value if any
    final currentFilter = ref.read(filterProvider);
    if (currentFilter.campus != null) {
      _campusController.text = currentFilter.campus!;
    }
  }

  @override
  void dispose() {
    _campusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(filterProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Center(
          child: Container(
            width: isMobile ? 0.9.sw : 0.45.sw,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      // CAMPUS SEARCH
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: TextField(
                          controller: _campusController,
                          decoration: InputDecoration(
                            hintText: "Search campus...",
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20.w,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            suffixIcon: _campusController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, size: 18.w, color: theme.colorScheme.onSurfaceVariant),
                                    onPressed: () {
                                      _campusController.clear();
                                      ref.read(filterProvider.notifier).setCampus(null);
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              ref.read(filterProvider.notifier).setCampus(null);
                            } else {
                              ref.read(filterProvider.notifier).setCampus(value);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 15.h),
                      
                      // ROOM TYPE DROPDOWN
                      DropdownButtonWidget(
                        icon: Icons.meeting_room_outlined,
                        label: "Room Type",
                        hint: "Single, Shared, etc.",
                        isFilter: true,
                        value: filter.roomType,
                        items: const [
                          "Single Room with washroom",
                          "Single Room self contain",
                          "Single Room with shared washroom",
                          "double Room self contain",
                          "Double Room with shared washroom",
                        ],
                        onChanged: (val) {
                          ref.read(filterProvider.notifier).setRoomType(val);
                        },
                      ),
                      SizedBox(height: 15.h),
                      
                      _buildSearchButton(context, isMobile),
                    ],
                  )
                : Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SmallText(text: "Campus", color: theme.colorScheme.onSurfaceVariant),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.dividerColor),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                controller: _campusController,
                                decoration: InputDecoration(
                                  hintText: "Search campus...",
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.search, size: 20.w, color: theme.colorScheme.onSurfaceVariant),
                                  suffixIcon: _campusController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, size: 18.w, color: theme.colorScheme.onSurfaceVariant),
                                          onPressed: () {
                                            _campusController.clear();
                                            ref.read(filterProvider.notifier).setCampus(null);
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    ref.read(filterProvider.notifier).setCampus(null);
                                  } else {
                                    ref.read(filterProvider.notifier).setCampus(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: DropdownButtonWidget(
                          icon: Icons.meeting_room_outlined,
                          label: "Room Type",
                          hint: "Single, Shared, etc.",
                          isFilter: true,
                          value: filter.roomType,
                          items: const [
                            "Single Room with washroom",
                            "Single Room self contain",
                            "Single Room with shared washroom",
                            "double Room self contain",
                            "Double Room with shared washroom",
                          ],
                          onChanged: (val) {
                            ref.read(filterProvider.notifier).setRoomType(val);
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _buildSearchButton(context, isMobile),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        _navigateToFilteredResults(context);
      },
      child: Container(
        margin: EdgeInsets.only(top: isMobile ? 12.h : 25.h),
        width: isMobile ? double.infinity : 120.w,
        height: isMobile ? 48 : 55.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: theme.colorScheme.onPrimary,
                size: isMobile ? 22 : 24.r),
            SizedBox(width: isMobile ? 6 : 5.w),
            SmallText(text: "Search", color: theme.colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }

  void _navigateToFilteredResults(BuildContext context) {
    // Switch to Hostels tab in the main AppBarScreen navigation
    final appBarScreenState = context.findAncestorStateOfType<AppBarScreenState>();
    
    if (appBarScreenState != null) {
      appBarScreenState.onNavSelected(1);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Showing filtered results in Hostels'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      GoRouter.of(context).push('/0');

    }
  }
}