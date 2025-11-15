import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/ui/widgets/dropdown_button_widet.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class FilterSection extends ConsumerStatefulWidget {
  const FilterSection({super.key});

  @override
  ConsumerState<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends ConsumerState<FilterSection> {
  late double _priceValue;
  late Map<String, bool> _amenities;
  final TextEditingController _campusController = TextEditingController();

  @override
  void dispose() {
    _campusController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeFromFilter();
  }

  void _initializeFromFilter() {
    final filter = ref.read(filterProvider);

    // Initialize price from filter or set to max (no filter)
    _priceValue = filter.maxPrice ?? 20000;

    _campusController.text = filter.campus ?? '';



    // Initialize amenities from filter
    _amenities = {
      "Wi-Fi": false,
      "Air Conditioning": false,
      "Kitchen": false,
      "Study Room": false,
      "Security": false,
      "Laundry": false,
    };

    // Set checked amenities based on current filter
    for (var amenity in filter.amenities) {
      if (_amenities.containsKey(amenity)) {
        _amenities[amenity] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(filterProvider);
    return Container(
      width: 0.25.sw,
      height: 0.75.sh,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconAndTextWidget(
                  icon: Icons.filter_alt_outlined,
                  text: "Filters",
                  iconColor: Colors.blueGrey,
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(filterProvider.notifier).clearFilters();
                    _initializeFromFilter();
                    setState(() {});
                  },
                  child: ElvButtonWidget(text: "Clear all", isFilter: true),
                ),
              ],
            ),

            SizedBox(height: 25.h),

            /// CAMPUS - WITH CONTROLLER
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallText(text: "Campus", color: Colors.blueGrey),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
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
                        color: Colors.grey,
                      ),
                      suffixIcon: _campusController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 18.w,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _campusController.clear();
                                ref
                                    .read(filterProvider.notifier)
                                    .setCampus(null);
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      // Real-time filtering as user types
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
            SizedBox(height: 25.h),
            SizedBox(height: 25.h),

            /// ROOM TYPE
            DropdownButtonWidget(
              icon: Icons.meeting_room_outlined,
              label: "Room Type",
              hint: "Single, Shared, etc.",
              value: filter.roomType, // Get current value from filter
              isFilter: true,
              items: [
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
            
            SizedBox(height: 25.h),

            /// GENDER
            DropdownButtonWidget(
              icon: Icons.people_outline,
              label: "Gender Preference",
              hint: "Select gender type",
              isFilter: true,
              value: filter.gender, // Get current value from filter
              items: ["Male", "Female", "Mixed"],
              onChanged: (val) {
                ref.read(filterProvider.notifier).setGender(val);
              },
            ),
            SizedBox(height: 25.h),

            /// PRICE RANGE
            SmallText(
              text: _priceValue == 20000
                  ? "Price Range (No max price)"
                  : "Price Range (Up to GHS ${_priceValue.round()})",
              color: Colors.blueGrey,
            ),
            Slider(
              value: _priceValue,
              min: 0,
              max: 20000,
              divisions: 20,
              label: _priceValue == 20000
                  ? "No limit"
                  : "GHS ${_priceValue.round()}",
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.grey.shade300,
              onChanged: (value) {
                setState(() => _priceValue = value);
                // Only set filter if not at max (no filter)
                final maxPrice = value == 20000 ? null : value;
                ref.read(filterProvider.notifier).setMaxPrice(maxPrice!);
              },
            ),

            SizedBox(height: 20.h),

            /// AMENITIES
            SmallText(text: "Amenities", color: Colors.blueGrey),
            SizedBox(height: 10.h),

            Wrap(
              runSpacing: 6.h,
              children: _amenities.keys.map((title) {
                return amenityCheck(title);
              }).toList(),
            ),

            SizedBox(height: 30.h),

          ],
        ),
      ),
    );
  }

  /// REUSABLE CHECKBOX BUILDER
  Widget amenityCheck(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          checkColor: Colors.white,
          activeColor: Colors.blueAccent,
          value: _amenities[title],
          onChanged: (val) {
            setState(() {
              _amenities[title] = val ?? false;
            });

            ref.read(filterProvider.notifier).toggleAmenity(title);
          },
        ),
        SmallText(text: title, color: Colors.black87),
      ],
    );
  }
}
