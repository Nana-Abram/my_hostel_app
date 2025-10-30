import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'small_text_widget.dart';

class DropdownButtonWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final String hint;
  final List<String> items;
  final bool isFilter;
  final Function(String?)? onChanged;
  final String? value;

  const DropdownButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.isFilter = false,
  });

  @override
  State<DropdownButtonWidget> createState() => _DropdownButtonWidgetState();
}

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL ROW
        Row(
          children: [
            Icon(
              widget.icon,
              color: Colors.blueGrey,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            SmallText(
              text: widget.label,
              color: Colors.blueGrey,
            ),
          ],
        ),

        SizedBox(height: 8.h),

        /// DROPDOWN FIELD
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: widget.isFilter ? Colors.blueGrey.shade200 : Colors.grey.shade400,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedValue,
              hint: Text(
                widget.hint,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: widget.items
                  .map((value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
