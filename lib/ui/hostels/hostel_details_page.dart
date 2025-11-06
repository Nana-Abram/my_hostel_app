import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/hostels/available_rooms.dart';
import 'package:my_hostel_app/ui/hostels/booking_card.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/elv_button_widget.dart';
import 'package:my_hostel_app/ui/widgets/icon_and_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class HostelDetailsPage extends StatelessWidget {
  const HostelDetailsPage({super.key});

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
      
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
        // margin: EdgeInsets.all(30.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconAndTextWidget(
                icon: Icons.arrow_back_ios,
                text: 'Back to search',
                iconColor: Colors.blueGrey,
                isBackArrow: true,
              ),
              SizedBox(height: 20.h),
              Stack(
                children: [
                  Container(
                    width: 1.sw,
                    height: 0.5.sh,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      image: DecorationImage(
                        image: AssetImage("assets/images/h1.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          
                  Positioned(
                    left: 30.h,
                    top: 40,
                    bottom: -30,
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade50,
                      maxRadius: 20.r,
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30.h,
                    top: 40,
                    bottom: -30,
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade50,
                      maxRadius: 20.r,
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.h),
              SmallText(text: 'Victory Towers', color: Colors.black),
              SizedBox(height: 20.h),
              Row(
                children: [
                  IconAndTextWidget(
                    icon: Icons.star,
                    text: '4.5',
                    iconColor: Colors.orange,
                    textColor: Colors.black,
                  ),
                  SizedBox(width: 5.w),
                  SmallText(text: "(126 reviews)"),
                  SizedBox(width: 10.w),
                  IconAndTextWidget(
                    icon: Icons.location_on_outlined,
                    text: "UENR Sunyani Campus",
                    iconColor: Colors.blueGrey,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                width: 0.5.sw,
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade400, width: 0.5.w),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.r,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BigText(text: "About this hostel",color: Colors.black,),
                    SizedBox(height: 10.h),
                    SmallText(
                      text:
                          "Modern student accommodation with excellent facilities. Located in the heart of North Campus, Victory Towers offers premium living spaces designed for student comfort and academic success.",
                          size: 10.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: 0.5.sw,
                padding: EdgeInsets.all(30.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade400, width: 0.5.w),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.r,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BigText(text: "Amenities",color: Colors.black,size: 12.sp,),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RowIconAndText(icon: Icons.wifi,text: "Wi-Fi"),
                          RowIconAndText(icon: Icons.wifi,text: "Kitchen"),
                            RowIconAndText(icon: Icons.wifi,text: "24/7 Security"),
                      ],
                    ),
                    SizedBox(height: 20.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RowIconAndText(icon: Icons.wifi,text: "Study Room"),
                          RowIconAndText(icon: Icons.wifi,text: "Free Water"),
                            RowIconAndText(icon: Icons.wifi,text: "Laundry"),
                      ],
                    ),

                  ],
                ),
              ),
              SizedBox(height: 30.h,),
              SmallText(text: "Available Rooms",color: Colors.black,),
              SizedBox(height: 30.h,),
              AvailableRooms()
                ],
              ),
            
            BookingCardWidget(price: "3000", duration: "semester",campus: "UENR campus",availableRooms: "3",  ratings: "4.5", onBook: () {},)
            ],
              ),
              SizedBox(height: 20.h,),
              Container(
                width: 0.65.sw,
                height: 0.40.sh,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.blueGrey.shade300,
                   boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.r,
                      offset: Offset(1, 1),
                    ),
                   ]
                ),
                child:Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(Icons.location_on_outlined,size: 50.sp, color: Colors.black,),
                 Center(child: BigText(text: "Location on map")),
                  ],
                )
              ),
              SizedBox(height: 50.h,)
            ]
        
          ),
        ),
      ),
    );
  }
}

class RowIconAndText extends StatelessWidget {
  const RowIconAndText({
    super.key,
    required this.icon,
    required this.text
  });
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color:AppColors.checkColor
          ),
          child: Icon(icon, size: 22.sp,color: AppColors.blueColor,),
        ),
        SizedBox(width: 10.w,),
        SmallText(text:text,color: Colors.black,)
      ],
    );
  }
}
