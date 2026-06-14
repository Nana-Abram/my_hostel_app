import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/ui/widgets/dropdown_button_widet.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class FilterSection extends ConsumerStatefulWidget {
  const FilterSection({super.key});

  @override
  ConsumerState<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends ConsumerState<FilterSection> {
  late RangeValues _priceRange;
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

    // Initialize price range from filter
    _priceRange = RangeValues(
      filter.minPrice ?? 0,
      filter.maxPrice ?? 20000,
    );

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
    final theme = Theme.of(context);
    final filter = ref.watch(filterProvider);
    
    return Container(
      width: 0.25.sw,
      height: 0.75.sh,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
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
            /// HEADER WITH ACTIVE FILTER COUNT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      color: theme.colorScheme.primary,
                      size: 24.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (filter.activeFilterCount > 0) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${filter.activeFilterCount}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (filter.hasActiveFilters)
                  GestureDetector(
                    onTap: () {
                      ref.read(filterProvider.notifier).clearFilters();
                      _initializeFromFilter();
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "Clear",
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 25.h),

            /// CAMPUS SEARCH
            _buildSectionTitle("Campus", Icons.school_outlined, theme),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8.r),
                color: theme.colorScheme.background,
              ),
              child: TextField(
                controller: _campusController,
                decoration: InputDecoration(
                  hintText: "Search campus...",
                  hintStyle: TextStyle(fontSize: 14.sp),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20.w,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _campusController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 18.w,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _campusController.clear();
                            ref.read(filterProvider.notifier).setCampus(null);
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.isEmpty) {
                    ref.read(filterProvider.notifier).setCampus(null);
                  } else {
                    ref.read(filterProvider.notifier).setCampus(value);
                  }
                },
              ),
            ),
            
            SizedBox(height: 25.h),

            /// ROOM TYPE
            _buildSectionTitle("Room Type", Icons.meeting_room_outlined, theme),
            SizedBox(height: 8.h),
            DropdownButtonWidget(
              icon: Icons.meeting_room_outlined,
              label: "",
              hint: "Select room type",
              value: filter.roomType,
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
            _buildSectionTitle("Gender Preference", Icons.people_outline, theme),
            SizedBox(height: 8.h),
            DropdownButtonWidget(
              icon: Icons.people_outline,
              label: "",
              hint: "Select gender",
              isFilter: true,
              value: filter.gender,
              items: ["Male", "Female", "Mixed"],
              onChanged: (val) {
                ref.read(filterProvider.notifier).setGender(val);
              },
            ),
            
            SizedBox(height: 25.h),

            /// PRICE RANGE WITH RANGE SLIDER
            _buildSectionTitle("Price Range", Icons.attach_money, theme),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "GHS ${_priceRange.start.round()}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    "to",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _priceRange.end == 20000
                        ? "No limit"
                        : "GHS ${_priceRange.end.round()}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 20000,
              divisions: 40,
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.dividerColor,
              labels: RangeLabels(
                'GHS ${_priceRange.start.round()}',
                _priceRange.end == 20000
                    ? 'No limit'
                    : 'GHS ${_priceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() => _priceRange = values);
                ref.read(filterProvider.notifier).setPriceRange(
                  values.start == 0 ? 0 : values.start,
                  values.end == 20000 ? 20000 : values.end,
                );
              },
            ),

            SizedBox(height: 20.h),

            /// AMENITIES
            _buildSectionTitle("Amenities", Icons.home_work_outlined, theme),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _amenities.keys.map((title) {
                return _buildAmenityChip(title, theme);
              }).toList(),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: theme.colorScheme.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(String title, ThemeData theme) {
    final isSelected = _amenities[title] ?? false;
    return FilterChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          _amenities[title] = val;
        });
        ref.read(filterProvider.notifier).toggleAmenity(title);
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
        width: 1.5,
      ),
      labelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
    );
  }

  /// REUSABLE CHECKBOX BUILDER (kept for backward compatibility)
  Widget amenityCheck(String title) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          checkColor: theme.colorScheme.onPrimary,
          activeColor: theme.colorScheme.primary,
          value: _amenities[title],
          onChanged: (val) {
            setState(() {
              _amenities[title] = val ?? false;
            });
            ref.read(filterProvider.notifier).toggleAmenity(title);
          },
        ),
        SmallText(text: title, color: theme.colorScheme.onSurface),
      ],
    );
  }
}
