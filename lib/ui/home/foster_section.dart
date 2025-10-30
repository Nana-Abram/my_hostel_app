import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0XFF111827),
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 30.w),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 700;

              return isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLogoAndDesc(),
                        SizedBox(height: 30.h),
                        _buildLinksSection(),
                        SizedBox(height: 30.h),
                        _buildLegalSection(),
                        SizedBox(height: 30.h),
                        _buildContactSection(),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLogoAndDesc(),
                        _buildLinksSection(),
                        _buildLegalSection(),
                        _buildContactSection(),
                      ],
                    );
            },
          ),
          SizedBox(height: 40.h),
          Divider(
            color: Colors.grey.shade700,
            thickness: 0.4,
            indent: 0.1.sw,
            endIndent: 0.1.sw,
          ),
          SizedBox(height: 30.h),
          Text(
            "© 2025 HostelHub. All rights reserved.",
            style: TextStyle(color: Colors.blueGrey, fontSize: 11.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // HostelHub logo + intro
  Widget _buildLogoAndDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.blueColor,
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
            Text(
              "HostelHub",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          "Your trusted platform for university\nhostel booking",
          style: TextStyle(color: Colors.blueGrey, fontSize: 13.sp),
        ),
      ],
    );
  }

  // Quick Links
  Widget _buildLinksSection() {
    return _buildFooterColumn(
      title: "Quick Links",
      links: ["About Us", "Hostels", "Contact"],
    );
  }

  // Legal
  Widget _buildLegalSection() {
    return _buildFooterColumn(
      title: "Legal",
      links: ["Terms of Service", "Privacy Policy", "Refund Policy"],
    );
  }

  // Contact Info
  Widget _buildContactSection() {
    return _buildFooterColumn(
      title: "Contact",
      links: [
        "University Campus",
        "Accra, Ghana",
        "info@hostelhub.edu.gh",
        "+233 24 848 4786",
      ],
    );
  }

  // Reusable column builder
  Widget _buildFooterColumn({
    required String title,
    required List<String> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 20.h),
        ...links.map(
          (link) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              link,
              style: TextStyle(color: Colors.blueGrey, fontSize: 13.sp),
            ),
          ),
        ),
      ],
    );
  }
}
