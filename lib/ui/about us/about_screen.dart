import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_hostel_app/ui/app_bar/app_bar_screen.dart';
import 'package:my_hostel_app/ui/core/app_colors.dart';
import 'package:my_hostel_app/ui/widgets/small_text_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER SECTION
              _buildHeaderSection(context, theme),
          const SizedBox(height: 60),

          // MISSION SECTION
          _buildMissionSection(theme),
          const SizedBox(height: 60),

          // FEATURES GRID
              _buildFeaturesSection(theme),
          const SizedBox(height: 60),

          // TEAM SECTION
          _buildTeamSection(theme),
          const SizedBox(height: 60),

          // STATS SECTION
          _buildStatsSection(),
          const SizedBox(height: 40),

          // CTA SECTION
          _buildCTASection(context, theme),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About HostelHub',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your Gateway to Comfortable Student Living',
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          height: 500.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            image: const DecorationImage(
              image: AssetImage('assets/images/new.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionSection(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'At HostelHub, we believe that finding the perfect student accommodation should be simple, transparent, and stress-free. We\'re dedicated to connecting students with safe, affordable, and comfortable living spaces near their educational institutions.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Our platform brings together hostel owners and students, creating a seamless marketplace that prioritizes safety, convenience, and community.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 60.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.school, size: 50.w, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'For Students',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                SmallText(
                  text:
                      'Find your perfect home away from home with verified listings and transparent pricing.',
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    final features = [
      {
        'icon': Icons.verified_user,
        'title': 'Verified Listings',
        'description':
            'Every hostel is personally verified for safety and quality standards',
      },
      {
        'icon': Icons.price_check,
        'title': 'Transparent Pricing',
        'description': 'No hidden costs. See exactly what you\'ll pay upfront',
      },
      {
        'icon': Icons.map,
        'title': 'Campus Proximity',
        'description':
            'Find hostels within walking distance to your institution',
      },
      {
        'icon': Icons.support_agent,
        'title': '24/7 Support',
        'description': 'Our team is always here to help you with any concerns',
      },
      {
        'icon': Icons.reviews,
        'title': 'Student Reviews',
        'description': 'Real feedback from students who\'ve lived there',
      },
      {
        'icon': Icons.payment,
        'title': 'Easy Booking',
        'description': 'Secure online booking with multiple payment options',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose HostelHub?',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We\'re revolutionizing student accommodation with technology and trust',
              style: TextStyle(fontSize: 13.sp, color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 600
                ? 280.w
                : constraints.maxWidth * 0.8;

            return Wrap(
              spacing: 30.w,
              runSpacing: 30.h,
              alignment: WrapAlignment.start,
              children: features.map((feature) {
                return Container(
                  width: cardWidth,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 32.w,
                              color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        feature['title'] as String,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature['description'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

Widget _buildTeamSection(ThemeData theme) {
  final team = [
    {
      'name': 'Kwabena Yeboah', 
      'role': 'Founder & CEO', 
      'image': 'assets/images/me.jpg'  // Asset path
    },
    {
      'name': 'saaka Ahmed', 
      'role': 'Tech Lead', 
      'image': 'assets/images/top2.jpg'
    },
    {
      'name': 'Emily Davis', 
      'role': 'Student Relations', 
      'image': 'assets/images/h2.jpg'
    },
    {
      'name': 'Osei Frank', 
      'role': 'Partnerships', 
      'image': 'assets/images/vegas1.jpg'
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Meet Our Team',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color:theme.colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Passionate individuals dedicated to improving student living',
        style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
      ),
      const SizedBox(height: 40),
      Wrap(
        spacing: 40.w,
        runSpacing: 40.h,
        alignment: WrapAlignment.start,
        children: team.map((member) {
          return SizedBox(
            width: 160.w,
            child: Column(
              children: [
                // ASSET IMAGE
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.blueColor.withOpacity(0.3),
                      width: 2.w,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      member['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image fails to load
                        return Container(
                          color: AppColors.blueColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 40.w,
                            color: AppColors.blueColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  member['name']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color:theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  member['role']!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}

  Widget _buildStatsSection() {
    final stats = [
      {'value': '500+', 'label': 'Hostels Listed'},
      {'value': '10,000+', 'label': 'Students Housed'},
      {'value': '15+', 'label': 'Campuses Served'},
      {'value': '98%', 'label': 'Satisfaction Rate'},
    ];

    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueColor, AppColors.blueColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) {
          return Column(
            children: [
              Text(
                stat['value']!,
                style: TextStyle(
                  fontSize: 38.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stat['label']!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Find Your Perfect Hostel?',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Join thousands of students who have found their ideal accommodation through HostelHub. Start your search today!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blueGrey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              
              onPressed: () {
                // Navigate to hostels screen
                final appBarScreenState = context
                    .findAncestorStateOfType<AppBarScreenState>();
                appBarScreenState?.onNavSelected(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Browse Hostels',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
