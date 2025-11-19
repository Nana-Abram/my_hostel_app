import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/core/dimensions.dart';
import 'package:my_hostel_app/ui/home/foster_section.dart';
import 'package:my_hostel_app/ui/widgets/avatar_and_text_wiget.dart';
import 'package:my_hostel_app/ui/widgets/big_text_widget.dart';
import 'package:my_hostel_app/ui/widgets/card_widget.dart';
import 'package:my_hostel_app/ui/home/search_container_widget.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of images for the carousel
  final List<String> images = [
    "assets/images/h1.jpg",
    "assets/images/top2.jpg",
    "assets/images/h2.jpg",
    "assets/images/vegas1.jpg",
    "assets/images/new.jpg",
    // "assets/images/vegas1.jpg",
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Carousel section
              CarouselSlider(
                items: images.map((img) {
                  return Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      // Gradient overlay for text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 700.h,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 10),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),

              //Indicator Dots (NEW)
              Positioned(
                bottom: 40.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      width: _currentIndex == entry.key ? 20.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: _currentIndex == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Overlay text + search box
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 100.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmallText(
                        text: "Find your perfect hostel on campus",
                        size: Dimensions.fontSmall12,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20.h),
                      BigText(
                        text: "Book Verified rooms easily and securely",
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      SizedBox(height: 20.h),
                      // The search container in the middle
                      SearchContainer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardWidget(
                firstText: "Verified Hostels",
                secondText:
                    "All hostels are verified and approved by the university administration",
                icon: Icons.check_circle_outlined,
                containerColor: AppColors.checkColor,
                iconColor: AppColors.blueColor,
              ),
              CardWidget(
                firstText: "Instant Booking",
                secondText:
                    "Book your room instantly with our streamlined booking process",
                icon: Icons.electric_bolt_outlined,
                containerColor: AppColors.instantColor,
                iconColor: AppColors.greenColor,
              ),
              CardWidget(
                firstText: "Secure Payment",
                secondText:
                    "Your payments are processed securely through trusted payment gateways",
                icon: Icons.shield_outlined,
                containerColor: AppColors.secureColor,
                iconColor: AppColors.orangeColor,
              ),
            ],
          ),
          SizedBox(height: 40.h),
          Container(
            width: double.infinity,
            height: 400.h,
            color: Color(0xFFF9FAFB),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                SmallText(text: "How It Works"),
                SmallText(
                  text: "Book your perfect hostel in three simple steps",
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AvatarAndTextWiget(
                      circleText: "1",
                      color: AppColors.blueColor,
                      firstText: "Search & Filter",
                      secondText:
                          "Browse hostels by campus, price and amenities to\n find your ideal match",
                    ),
                    AvatarAndTextWiget(
                      circleText: "2",
                      color: AppColors.greenColor,
                      firstText: "Search & Filter",
                      secondText:
                          "Choose from available rooms and view detailed\n information and photos",
                    ),
                    AvatarAndTextWiget(
                      circleText: "3",
                      color: AppColors.orangeColor,
                      firstText: "Search & Filter",
                      secondText:
                          "Complete your booking with secure payment and\n receive instant confirmation",
                    ),
                  ],
                ),
              ],
            ),
          ),
             FooterSection(),
           ],
      ),
    );
  }
}
