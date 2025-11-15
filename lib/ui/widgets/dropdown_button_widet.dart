import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'small_text_widget.dart';

class DropdownButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool isFilter;
  final List<String> items;
  final String? value; // Add this
  final Function(String?)? onChanged;

  const DropdownButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.isFilter,
    required this.items,
    this.value, // Add this
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallText(text: label, color: Colors.blueGrey),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, // Use the value here
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, size: 24.w),
              hint: SmallText(text: hint),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: SmallText(text: item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}