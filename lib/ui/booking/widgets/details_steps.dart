import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/ui/booking/widgets/booking_summary.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class DetailsStep extends StatefulWidget {
  final HostelModel hostel;
  final RoomModel room;
  final VoidCallback onNextStep;
  final Function(String, String) onFormDataUpdate;
  final Map<String, String> initialData;

  const DetailsStep({
    super.key,
    required this.hostel,
    required this.room,
    required this.onNextStep,
    required this.onFormDataUpdate,
    required this.initialData,
  });

  @override
  State<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<DetailsStep> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _checkInDateController = TextEditingController();
  final TextEditingController _specialRequestsController = TextEditingController();

  bool _fullNameValid = true;
  bool _emailValid = true;
  bool _phoneValid = true;
  bool _checkInDateValid = true;

  bool get _isFormValid {
    return _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _checkInDateController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    _fullNameController.text = widget.initialData['fullName'] ?? '';
    _emailController.text = widget.initialData['email'] ?? '';
    _phoneController.text = widget.initialData['phone'] ?? '';
    _checkInDateController.text = widget.initialData['checkInDate'] ?? '';
    _specialRequestsController.text = widget.initialData['specialRequests'] ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _checkInDateController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _fullNameValid = _fullNameController.text.isNotEmpty;
      _emailValid = _emailController.text.isNotEmpty;
      _phoneValid = _phoneController.text.isNotEmpty;
      _checkInDateValid = _checkInDateController.text.isNotEmpty;
    });

    if (_isFormValid) {
      // Save form data
      widget.onFormDataUpdate('fullName', _fullNameController.text);
      widget.onFormDataUpdate('email', _emailController.text);
      widget.onFormDataUpdate('phone', _phoneController.text);
      widget.onFormDataUpdate('checkInDate', _checkInDateController.text);
      widget.onFormDataUpdate('specialRequests', _specialRequestsController.text);
      
      widget.onNextStep();
    }
  }

  void _validateField(String fieldName, String value) {
    setState(() {
      switch (fieldName) {
        case 'fullName':
          _fullNameValid = value.isNotEmpty;
          break;
        case 'email':
          _emailValid = value.isNotEmpty;
          break;
        case 'phone':
          _phoneValid = value.isNotEmpty;
          break;
        case 'checkInDate':
          _checkInDateValid = value.isNotEmpty;
          break;
      }
    });
    
    // Update form data in real-time
    widget.onFormDataUpdate(fieldName, value);
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        final dateText = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
        _checkInDateController.text = dateText;
        _validateField('checkInDate', dateText);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Section
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BigText(text: "Book Your Room", color: Colors.black),
                SizedBox(height: 10.h),
                SmallText(
                  text: "Please fill in the details below to complete your booking.",
                  color: Colors.blueGrey,
                ),
                SizedBox(height: 30.h),

                // Form fields
                _buildTextField(
                  label: "Full Name *",
                  controller: _fullNameController,
                  isValid: _fullNameValid,
                  fieldName: 'fullName',
                  hintText: "Enter your full name",
                ),
                SizedBox(height: 20.h),

                _buildTextField(
                  label: "Email Address *",
                  controller: _emailController,
                  isValid: _emailValid,
                  fieldName: 'email',
                  hintText: "Enter your email address",
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.h),

                _buildTextField(
                  label: "Phone Number *",
                  controller: _phoneController,
                  isValid: _phoneValid,
                  fieldName: 'phone',
                  hintText: "Enter your phone number",
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20.h),

                _buildTextField(
                  label: "Check-in Date *",
                  controller: _checkInDateController,
                  isValid: _checkInDateValid,
                  fieldName: 'checkInDate',
                  hintText: "Select your check-in date",
                  readOnly: true,
                  onTap: () => _showDatePicker(context),
                ),
                SizedBox(height: 20.h),

                _buildTextField(
                  label: "Special Requests (Optional)",
                  controller: _specialRequestsController,
                  isValid: true,
                  fieldName: 'specialRequests',
                  hintText: "Any special requirements or requests",
                  maxLines: 3,
                ),
                SizedBox(height: 40.h),

                // Proceed button
                Center(
                  child: ElvButtonWidget(
                    text: "Proceed to Payment",
                    isPrimary: _isFormValid,
                    onPressed: _isFormValid ? _validateForm : null,
                  ),
                ),

                // Validation message
                if (!_isFormValid) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: SmallText(
                            text: "Please fill in all required fields (*) to continue",
                            color: Colors.orange.shade800,
                            size: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        SizedBox(width: 50.w),

        // Summary Section
        Expanded(
          flex: 1,
          child: BookingSummaryCard(hostel: widget.hostel, room: widget.room),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isValid,
    required String fieldName,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SmallText(text: label, color: Colors.black),
            if (label.contains('*'))
              Text(
                " ",
                style: TextStyle(color: Colors.red, fontSize: 12.sp),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isValid ? Colors.grey.shade300 : Colors.red.shade400,
              width: isValid ? 1 : 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              maxLines: maxLines,
              onChanged: (value) => _validateField(fieldName, value),
              onTap: onTap,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12.sp,
                ),
                errorText: isValid ? null : "This field is required",
                errorStyle: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.red.shade600,
                ),
              ),
              style: TextStyle(fontSize: 12.sp, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}