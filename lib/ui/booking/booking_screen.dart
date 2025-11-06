import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/widgets/avatar_and_text_wiget.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class BookingScreen extends StatelessWidget {
  final String roomType;
  final double price;
  final String imagePath;

  const BookingScreen({
    super.key,
    required this.roomType,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         backgroundColor:const Color(0xFFF9FAFB),
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
              // ===== LEFT SIDE (LOGO + NAME) =====
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

              // ===== RIGHT SIDE (BUTTONS) =====
              Row(
                children: [
                  ElvButtonWidget(text: "Login", onPressed: () {}),
                  SizedBox(width: 16.w),
                  ElvButtonWidget(
                    text: "Sign Up",
                    onPressed: () {},
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      body:SingleChildScrollView(
         child: Column(
           children: [
              Padding(
                padding:  EdgeInsets.only(top: 20.h,left: 20.w),
                child: IconAndTextWidget(
                    icon: Icons.arrow_back_ios,
                    text: 'Back',
                    iconColor: Colors.blueGrey,
                    isBackArrow: true,
                  ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              AvatarAndTextWiget(circleText: "1", color: AppColors.blueColor, firstText: "Details", secondText:"",avatarRadius: 20,),
              AvatarAndTextWiget(circleText: "2", color: AppColors.blueColor, firstText: "Payment", secondText:"",avatarRadius: 20,),
              AvatarAndTextWiget(circleText: "1", color: AppColors.blueColor, firstText: "Confirmation", secondText:"",avatarRadius: 20,),
              ],),
             SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 40.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// LEFT SIDE: BOOKING FORM
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
                            _buildTextField(label: "Full Name"),
                            SizedBox(height: 20.h),
             
                            // STUDENT ID
                            _buildTextField(label: "Student ID / Index Number"),
                            SizedBox(height: 20.h),
             
                            // EMAIL
                            _buildTextField(label: "Email Address"),
                            SizedBox(height: 20.h),
             
                            // PHONE NUMBER
                            _buildTextField(label: "Phone Number"),
                            SizedBox(height: 20.h),
             
                            // CHECK-IN DATE
                            _buildTextField(label: "Check-in Date"),
                            SizedBox(height: 20.h),
             
                            // DURATION
                            _buildDropdownField(
                              label: "Duration",
                              items: [
                                "1 Semester",
                                "2 Semesters",
                                "Full Academic Year",
                              ],
                            ),
                            SizedBox(height: 40.h),
             
                            Center(
                              child: ElvButtonWidget(
                                text: "Proceed to Payment",
                                isPrimary: true,
                                onPressed: () {
                                  // TODO: handle booking confirmation or navigate to payment
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
             
                    SizedBox(width: 50.w),
             
                    /// RIGHT SIDE: SUMMARY CARD
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 0.8.sh,
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
                            /// IMAGE SECTION
                            Container(
                              height: 0.3.sh,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  topRight: Radius.circular(20.r),
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(imagePath),
                                ),
                              ),
                            ),
             
                            /// BOOKING DETAILS
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
             
                                  _summaryRow("Room Type", roomType),
                                  _summaryRow("Campus", "UENR Sunyani Campus"),
                                  _summaryRow("Duration", "1 Semester"),
                                  _summaryRow("Price", "GHS ${price.toStringAsFixed(2)}"),
                                  _summaryRow("Service Fee", "GHS 50.00"),
                                  const Divider(),
                                  _summaryRow(
                                    "Total",
                                    "GHS ${(price + 50).toStringAsFixed(2)}",
                                    isBold: true,
                                  ),
                                  SizedBox(height: 30.h),
             
                                  Center(
                                    child: ElvButtonWidget(
                                      text: "Confirm Booking",
                                      isPrimary: true,
                                      onPressed: () {
                                        // TODO: confirm booking logic
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                   ),
           ],
         ),
       ),
    );
  }

  /// REUSABLE TEXT FIELD
  Widget _buildTextField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallText(text: label, color: Colors.black),
        SizedBox(height: 6.h),
        Container(
          height: 55.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// REUSABLE DROPDOWN FIELD
  Widget _buildDropdownField({required String label, required List<String> items}) {
    String? selectedValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallText(text: label, color: Colors.black),
        SizedBox(height: 6.h),
        Container(
          height: 55.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              hint: SmallText(text: "Select Duration", color: Colors.blueGrey),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: SmallText(text: e, color: Colors.black),
                    ),
                  )
                  .toList(),
              onChanged: (value) {},
            ),
          ),
        ),
      ],
    );
  }

  /// SUMMARY ROW BUILDER
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
