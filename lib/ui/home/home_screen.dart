import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_hostel_app/ui/core/responsive.dart';
import 'package:my_hostel_app/ui/home/foster_section.dart';
import 'package:my_hostel_app/ui/home/image_container.dart';
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
  final List<String> images = [
    'assets/images/h1.jpg',
    'assets/images/top2.jpg',
    'assets/images/h2.jpg',
    'assets/images/vegas1.jpg',
    'assets/images/new.jpg',
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Hero carousel ────────────────────────────────────────────────
          _buildHero(r, theme),

          SizedBox(height: r.spacingXL),

          // ── Feature cards ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.pagePadding),
            child: _buildFeatureCards(r),
          ),

          SizedBox(height: r.spacingXL),

          // ── Image carousel ────────────────────────────────────────────────
          const ImageContainer(),

          SizedBox(height: r.spacingXL),

          // ── How it works ──────────────────────────────────────────────────
          _buildHowItWorks(r, theme),

          // ── Footer ────────────────────────────────────────────────────────
          const FooterSection(),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHero(Responsive r, ThemeData theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Carousel
        CarouselSlider(
          items: images.map((img) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(img, fit: BoxFit.cover, width: double.infinity),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF000000).withOpacity(0.6),
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
            height: r.heroHeight,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 8),
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
        ),

        // Indicator dots
        Positioned(
          bottom: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              final active = _currentIndex == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(active ? 1.0 : 0.4),
                ),
              );
            }).toList(),
          ),
        ),

        // Overlay: headline + search
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmallText(
                text: 'Find your perfect hostel on campus',
                size: r.bodySmall,
                color: Colors.white,
              ),
              SizedBox(height: r.spacingM),
              BigText(
                text: 'Book Verified Rooms Easily and Securely',
                color: Colors.white,
                size: r.h3,
              ),
              SizedBox(height: r.spacingM),
              const SearchContainer(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Feature cards ─────────────────────────────────────────────────────────

  Widget _buildFeatureCards(Responsive r) {
    final cards = [
      const _FeatureData(
        title: 'Verified Hostels',
        text:
            'All hostels are verified and approved by the university administration',
        icon: Icons.check_circle_outlined,
        containerColor: Color(0xFFE3F2FD),
        iconColor: Color(0xFF2196F3),
      ),
      const _FeatureData(
        title: 'Instant Booking',
        text:
            'Book your room instantly with our streamlined booking process',
        icon: Icons.electric_bolt_outlined,
        containerColor: Color(0xFFE8F5E9),
        iconColor: Color(0xFF4CAF50),
      ),
      const _FeatureData(
        title: 'Secure Payment',
        text:
            'Your payments are processed securely through trusted payment gateways',
        icon: Icons.shield_outlined,
        containerColor: Color(0xFFFFF3E0),
        iconColor: Color(0xFFFF9800),
      ),
    ];

    if (r.isMobile) {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: EdgeInsets.only(bottom: r.spacingM),
                  child: CardWidget(
                    firstText: c.title,
                    secondText: c.text,
                    icon: c.icon,
                    containerColor: c.containerColor,
                    iconColor: c.iconColor,
                  ),
                ))
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards
          .map((c) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.spacingS),
                  child: CardWidget(
                    firstText: c.title,
                    secondText: c.text,
                    icon: c.icon,
                    containerColor: c.containerColor,
                    iconColor: c.iconColor,
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ── How it works ──────────────────────────────────────────────────────────

  Widget _buildHowItWorks(Responsive r, ThemeData theme) {
    final steps = [
      (
        num: '1',
        color: const Color(0xFF2196F3),
        title: 'Search & Filter',
        desc: 'Browse hostels by campus, price and amenities to find your ideal match',
      ),
      (
        num: '2',
        color: const Color(0xFF4CAF50),
        title: 'Pick Your Room',
        desc: 'Choose from available rooms and view detailed information and photos',
      ),
      (
        num: '3',
        color: const Color(0xFFFF9800),
        title: 'Book & Confirm',
        desc: 'Complete your booking with secure payment and receive instant confirmation',
      ),
    ];

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: EdgeInsets.symmetric(
        vertical: r.sectionPaddingV,
        horizontal: r.pagePadding,
      ),
      child: Column(
        children: [
          SmallText(text: 'How It Works', size: r.h4),
          SizedBox(height: r.spacingS),
          SmallText(
            text: 'Book your perfect hostel in three simple steps',
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(height: r.spacingXL),
          r.isMobile
              ? Column(
                  children: steps
                      .map((s) => Padding(
                            padding: EdgeInsets.only(bottom: r.spacingL),
                            child: AvatarAndTextWiget(
                              circleText: s.num,
                              color: s.color,
                              firstText: s.title,
                              secondText: s.desc,
                            ),
                          ))
                      .toList(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: steps
                      .map((s) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: r.spacingM),
                              child: AvatarAndTextWiget(
                                circleText: s.num,
                                color: s.color,
                                firstText: s.title,
                                secondText: s.desc,
                              ),
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final String title;
  final String text;
  final IconData icon;
  final Color containerColor;
  final Color iconColor;
  const _FeatureData({
    required this.title,
    required this.text,
    required this.icon,
    required this.containerColor,
    required this.iconColor,
  });
}