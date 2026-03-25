import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:my_hostel_app/ui/app_bar/app_bar_screen.dart';

class ImageContainer extends StatefulWidget {
  const ImageContainer({super.key});

  @override
  State<ImageContainer> createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // 6 hostel images
  final List<String> _images = [
    'assets/images/h3.jpg',
    'assets/images/h4.jpg',
    'assets/images/h5.jpg',
    'assets/images/h6.jpg', // Duplicated to have 6 cards
    'assets/images/h7.jpg',
    'assets/images/h4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _carouselController.nextPage(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: _images.length,
      itemBuilder: (context, index, realIndex) {
        return _ImageCard(
          imagePath: _images[index],
          index: index,
          isCenter: _isCenterCard(index),
        );
      },
      options: CarouselOptions(
        height: 420.h,
        viewportFraction: 0.32,
        initialPage: 0,
        enableInfiniteScroll: true,
        autoPlay: false, // Handled by timer for better control
        enlargeCenterPage: true,
        enlargeFactor: 0.15,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
    );
  }

  bool _isCenterCard(int index) {
    // Calculate if this card is in the center position
    return index == _currentPage;
  }
}

class _ImageCard extends StatefulWidget {
  final String imagePath;
  final int index;
  final bool isCenter;

  const _ImageCard({
    required this.imagePath,
    required this.index,
    required this.isCenter,
  });

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _elevationAnimation = Tween<double>(begin: 8.0, end: 25.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get base scale and elevation based on position
    final double baseScale = widget.isCenter ? 1.0 : 0.85;
    final double baseElevation = widget.isCenter ? 16.0 : 6.0;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double currentScale = baseScale + (_scaleAnimation.value - 1.0);
          final double currentElevation = baseElevation + (_elevationAnimation.value - 8.0);
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            child: Transform.scale(
              scale: currentScale,
              child: GestureDetector(
                onTap: () {
                  //  GoRouter.of(context).push('/0');
                  _navigateToFilteredResults(context);
               },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.2),
                        blurRadius: currentElevation,
                        spreadRadius: widget.isCenter ? 4 : 2,
                        offset: Offset(0, currentElevation / 2),
                      ),
                      if (widget.isCenter)
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      if (_isHovered)
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 35,
                          spreadRadius: 0,
                          offset: const Offset(0, 15),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                        ),
                        
                        // Gradient overlay (subtle, appears on hover or center)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: (_isHovered || widget.isCenter) ? 1.0 : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  theme.colorScheme.primary.withOpacity(
                                    widget.isCenter ? 0.35 : 0.25,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Border effect
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: widget.isCenter || _isHovered
                                  ? theme.colorScheme.primary.withOpacity(0.9)
                                  : Colors.transparent,
                              width: widget.isCenter ? 4 : 3,
                            ),
                          ),
                        ),
                        
                        // Center indicator badge (optional)
                        if (widget.isCenter)
                          Positioned(
                            top: 16.h,
                            right: 16.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.onPrimary,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Featured',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
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
              ),
            ),
          );
        },
      ),
    );
  }

   void _navigateToFilteredResults(BuildContext context) {
    // Switch to Hostels tab in the main AppBarScreen navigation
    final appBarScreenState = context.findAncestorStateOfType<AppBarScreenState>();
    
    if (appBarScreenState != null) {
      appBarScreenState.onNavSelected(1);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Showing filtered results in Hostels'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      GoRouter.of(context).push('/0');

    }
  }
}