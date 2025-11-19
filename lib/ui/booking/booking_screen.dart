import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/model/room_model.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/routes/app_routes.dart';
import 'package:my_hostel_app/ui/widgets/avatar_and_text_wiget.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final RoomModel selectedRoom;
  final HostelModel selectedHostel;

  const BookingScreen({
    super.key,
    required this.selectedRoom,
    required this.selectedHostel,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _currentStep = 1;

  // Text editing controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _indexNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _checkInDateController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();

  // Validation states
  bool _fullNameValid = true;
  bool _indexNumberValid = true;
  bool _emailValid = true;
  bool _phoneValid = true;
  bool _checkInDateValid = true;

  // Form validation
  bool get _isFormValid {
    return _fullNameController.text.isNotEmpty &&
        _indexNumberController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _checkInDateController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _indexNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _checkInDateController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _fullNameValid = _fullNameController.text.isNotEmpty;
      _indexNumberValid = _indexNumberController.text.isNotEmpty;
      _emailValid = _emailController.text.isNotEmpty;
      _phoneValid = _phoneController.text.isNotEmpty;
      _checkInDateValid = _checkInDateController.text.isNotEmpty;
    });

    if (_isFormValid) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  void _validateField(String fieldName, String value) {
    setState(() {
      switch (fieldName) {
        case 'fullName':
          _fullNameValid = value.isNotEmpty;
          break;
        case 'indexNumber':
          _indexNumberValid = value.isNotEmpty;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: Container(
          height: 120.h,
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'H',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  const Text(
                    "HostelHub",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ElvButtonWidget(text: "Login", onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.loginScreen);
                  }),
                  SizedBox(width: 16.w),
                  ElvButtonWidget(
                    text: "Sign Up",
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.signUpScreen);
                    },
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.h, left: 20.w),
              child: GestureDetector(
                onTap: () {
                  if (_currentStep > 1) {
                    setState(() {
                      _currentStep--;
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: IconAndTextWidget(
                  icon: Icons.arrow_back_ios,
                  text: 'Back',
                  iconColor: Colors.blueGrey,
                  isBackArrow: true,
                ),
              ),
            ),

            _buildProgressSteps(),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 40.h),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = ["Details", "Payment", "Confirmation"];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index <= _currentStep - 1;
          final isLast = index == steps.length - 1;

          return AvatarAndTextWiget(
            circleText: "${index + 1}",
            color: isActive ? AppColors.blueColor : Colors.blueGrey.shade400,
            firstText: step,
            secondText: "",
            avatarRadius: 25,
            isBold: isActive,
            needsDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildDetailsFormStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return _buildDetailsFormStep();
    }
  }

  Widget _buildDetailsFormStep() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  text:
                      "Please fill in the details below to complete your booking.",
                  color: Colors.blueGrey,
                ),
                SizedBox(height: 30.h),

                // FULL NAME
                _buildTextField(
                  label: "Full Name *",
                  controller: _fullNameController,
                  isValid: _fullNameValid,
                  fieldName: 'fullName',
                  hintText: "Enter your full name",
                ),
                SizedBox(height: 20.h),

                // STUDENT ID
                _buildTextField(
                  label: "Index Number/Reference Number *",
                  controller: _indexNumberController,
                  isValid: _indexNumberValid,
                  fieldName: 'indexNumber',
                  hintText: "Enter your index number",
                ),
                SizedBox(height: 20.h),

                // EMAIL
                _buildTextField(
                  label: "Email Address *",
                  controller: _emailController,
                  isValid: _emailValid,
                  fieldName: 'email',
                  hintText: "Enter your email address",
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.h),

                // PHONE NUMBER
                _buildTextField(
                  label: "Phone Number *",
                  controller: _phoneController,
                  isValid: _phoneValid,
                  fieldName: 'phone',
                  hintText: "Enter your phone number",
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20.h),

                // CHECK-IN DATE
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

                // SPECIAL REQUESTS (Optional)
                _buildTextField(
                  label: "Special Requests (Optional)",
                  controller: _specialRequestsController,
                  isValid: true, // Always valid since optional
                  fieldName: 'specialRequests',
                  hintText: "Any special requirements or requests",
                  maxLines: 3,
                ),
                SizedBox(height: 20.h),

                SizedBox(height: 40.h),

                Center(
                  child: ElvButtonWidget(
                    text: "Proceed to Payment",
                    isPrimary: _isFormValid,
                    onPressed: _isFormValid
                        ? () {
                            _validateForm();
                          }
                        : null,
                  ),
                ),

                // Validation summary
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
                            text:
                                "Please fill in all required fields (*) to continue",
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

        Expanded(flex: 1, child: _buildSummaryCard()),
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
        // if (!isValid) ...[
        //   SizedBox(height: 4.h),
        //   Text(
        //     "This field is required",
        //     style: TextStyle(
        //       color: Colors.red.shade600,
        //       fontSize: 10.sp,
        //     ),
        //   ),
        // ],
      ],
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _checkInDateController.text =
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
        _validateField('checkInDate', _checkInDateController.text);
      }
    });
  }

  Widget _buildSummaryCard() {
    final roomImage = widget.selectedRoom.image.isNotEmpty
        ? widget.selectedRoom.image
        : (widget.selectedHostel.images.isNotEmpty
              ? widget.selectedHostel.images.first
              : '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              color: Colors.grey.shade200,
            ),
            child: roomImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    child: ImageNetwork(
                      image: roomImage,
                      height: 200.h,
                      width: 450.w,
                      fitAndroidIos: BoxFit.cover,
                      fitWeb: BoxFitWeb.cover,
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.hotel,
                      size: 60.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),

          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BigText(
                  text: "Booking Summary",
                  color: Colors.black,
                  size: 16.sp,
                ),
                SizedBox(height: 20.h),

                _summaryRow("Hostel", widget.selectedHostel.name),
                _summaryRow("Room Type", widget.selectedRoom.type),
                _summaryRow("Campus", widget.selectedHostel.campus),
                _summaryRow("Duration", "One semester"),
                _summaryRow(
                  "Price",
                  "GHS ${widget.selectedRoom.price.toStringAsFixed(2)}",
                ),
                const Divider(),
                _summaryRow(
                  "Total",
                  "GHS ${widget.selectedRoom.price.toStringAsFixed(2)}",
                  isBold: true,
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Center(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment, size: 60.sp, color: AppColors.blueColor),
            SizedBox(height: 20.h),
            BigText(text: "Payment", color: Colors.black),
            SizedBox(height: 10.h),
            SmallText(
              text: "Payment step coming soon...",
              color: Colors.blueGrey,
            ),
            SizedBox(height: 30.h),
            ElvButtonWidget(
              text: "Complete Booking",
              isPrimary: true,
              onPressed: () {
                setState(() {
                  _currentStep = 3;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Center(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 80.sp, color: Colors.green),
            SizedBox(height: 20.h),
            BigText(text: "Booking Confirmed!", color: Colors.black),
            SizedBox(height: 10.h),
            SmallText(
              text:
                  "Your ${widget.selectedRoom.type} room at ${widget.selectedHostel.name} has been booked successfully.",
              color: Colors.blueGrey,
            ),
            SizedBox(height: 30.h),
            ElvButtonWidget(
              text: "Back to Home",
              isPrimary: true,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmallText(text: title, color: Colors.blueGrey),
          SmallText(
            text: value,
            color: isBold ? AppColors.blueColor : Colors.black,
            size: isBold ? 12.sp : 10.sp,
          ),
        ],
      ),
    );
  }
}
