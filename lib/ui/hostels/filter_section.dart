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
  double _priceValue = 5000; // Default slider price

  @override
  Widget build(BuildContext context) {
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
                    setState(() {
                      _priceValue = 0; // reset UI slider
                    });
                  },
                  child: ElvButtonWidget(text: "Clear all", isFilter: true),
                ),
              ],
            ),

            SizedBox(height: 25.h),

            /// CAMPUS DROPDOWN
            DropdownButtonWidget(
              icon: Icons.location_on_outlined,
              label: "Campus",
              hint: "Select campus",
              isFilter: true,
              items: [
                'UENR Sunyani campus',
                "UNER Dormaa campus",
                'KSTU Sunyani campus',
              ],
              onChanged: (val) {
                ref.read(filterProvider.notifier).setCampus(val);
              },
            ),
            SizedBox(height: 25.h),

            /// ROOM TYPE DROPDOWN
            DropdownButtonWidget(
              icon: Icons.meeting_room_outlined,
              label: "Room Type",
              hint: "Single, Shared, etc.",
              isFilter: true,
              items: [
                "One in a room",
                "Two in a room",
                "Three in a roow",
                "Four in a room",
              ],
              onChanged: (val) {
                ref.read(filterProvider.notifier).setRoomType(val);
              },
            ),
            SizedBox(height: 25.h),

            /// GENDER DROPDOWN
            DropdownButtonWidget(
              icon: Icons.people_outline,
              label: "Gender Preference",
              hint: "Select gender type",
              items: ["Male", "Female", "Mixed"],
              isFilter: true,
              onChanged: (val) {
                ref.read(filterProvider.notifier).setGender(val);
              },
            ),
            SizedBox(height: 25.h),

            /// PRICE RANGE
            SmallText(
              text: "Price Range (GHS 0 - GHS 20,000 / semester)",
              color: Colors.blueGrey,
            ),
            Slider(
              value: _priceValue,
              min: 0,
              max: 20000,
              divisions: 20,
              label: "GHS ${_priceValue.round()}",
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.grey.shade300,
              onChanged: (value) {
                setState(() {
                  _priceValue = value;
                });
              },
            ),
            SizedBox(height: 15.h),

            /// AMENITIES CHECKBOXES
            SmallText(text: "Amenities", color: Colors.blueGrey),
            SizedBox(height: 10.h),
            Wrap(
              runSpacing: 6.h,
              children: [
                amenityCheck("Wi-Fi"),
                amenityCheck("Air Conditioning"),
                amenityCheck("Kitchen"),
                amenityCheck("Study Room"),
                amenityCheck("Security"),
                amenityCheck("Laundry"),
              ],
            ),

            SizedBox(height: 25.h),

            /// APPLY BUTTON
            Center(
              child: ElvButtonWidget(
                text: "Apply Filters",
                isPrimary: true,
                onPressed: () {
                  // Later: Apply filter logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  final Map<String, bool> _amenities = {
    "Wi-Fi": false,
    "Air Conditioning": false,
    "Kitchen": false,
    "Study Room": false,
    "Security": false,
    "Laundry": false,
  };

  // Reusable amenity checkbox
  Widget amenityCheck(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Checkbox(
            checkColor: Colors.amber,
            value: _amenities[title],
            onChanged: (val) {
              setState(() {
                ref.read(filterProvider.notifier).toggleAmenity(title);

              });
            },
            activeColor: Colors.blueAccent,
          ),
          SmallText(text: title, color: Colors.black87),
        ],
      ),
    );
  }
}
