import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_network/image_network.dart';

/// Enhanced cached network image with progressive loading, error handling, and shimmer effect.
///
/// On mobile/desktop this is backed by [CachedNetworkImage] so images are cached to disk
/// (no re-download on revisit) and decoded at [width]x[height] instead of full resolution.
///
/// On web it falls back to [ImageNetwork], which renders via a native HTML `<img>` element.
/// Flutter Web's Skia/CanvasKit image codec can't decode a meaningful fraction of real-world
/// JPEGs (throws `EncodingError: The source image cannot be decoded`) — the browser's native
/// decoder handles them fine, which is what ImageNetwork uses under the hood for web.
class EnhancedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showShimmer;
  final VoidCallback? onTap;

  const EnhancedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.showShimmer = true,
    this.onTap,
  });

  Widget _buildPlaceholder() {
    return placeholder ??
        (showShimmer
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.grey[300],
                ),
              )
            : Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ));
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Icon(
          Icons.broken_image_outlined,
          size: 48.w,
          color: Colors.grey[600],
        );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: ImageNetwork(
            image: imageUrl,
            height: height ?? 200,
            width: width ?? 200,
            fitWeb: fit == BoxFit.cover ? BoxFitWeb.cover : BoxFitWeb.contain,
            onLoading: _buildPlaceholder(),
            onError: _buildErrorWidget(),
          ),
        ),
      );
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final hasFiniteWidth = width != null && width!.isFinite;
    final hasFiniteHeight = height != null && height!.isFinite;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: hasFiniteWidth ? (width! * dpr).round() : null,
          memCacheHeight: hasFiniteHeight ? (height! * dpr).round() : null,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      ),
    );
  }
}

/// Image with zoom and pinch functionality - opens in fullscreen viewer
class ZoomableImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final List<String>? gallery; // For gallery mode with multiple images
  final int? initialIndex;

  const ZoomableImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.gallery,
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImageLightbox(
              images: gallery ?? [imageUrl],
              initialIndex: initialIndex ?? 0,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      child: Hero(
        tag: 'image_$imageUrl',
        child: EnhancedCachedImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// Full screen image lightbox/viewer with pinch-to-zoom and swipe navigation
class ImageLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageLightbox({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<ImageLightbox> createState() => _ImageLightboxState();
}

class _ImageLightboxState extends State<ImageLightbox> {
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image viewer with pinch-to-zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _transformationController.value = Matrix4.identity();
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'image_${widget.images[index]}',
                    child: EnhancedCachedImage(
                      imageUrl: widget.images[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      showShimmer: false,
                      placeholder: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Navigation arrows (for desktop/web)
          if (widget.images.length > 1) ...[
            // Left arrow
            if (_currentIndex > 0)
              Positioned(
                left: 20.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 32.w),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            
            // Right arrow
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 20.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 32.w),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
          ],

          // Image dots indicator at bottom
          if (widget.images.length > 1)
            Positioned(
              bottom: 30.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: index == _currentIndex ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lazy loading grid view for images - loads images as they scroll into view
class LazyImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double aspectRatio;
  final double spacing;
  final void Function(int index)? onImageTap;

  const LazyImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 3,
    this.aspectRatio = 1.0,
    this.spacing = 8.0,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return ZoomableImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(8.r),
          gallery: imageUrls,
          initialIndex: index,
        );
      },
    );
  }
}

/// Enhanced carousel with lazy loading and progressive image loading
class EnhancedImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final double? width;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final bool showArrows;
  final BorderRadius? borderRadius;

  const EnhancedImageCarousel({
    super.key,
    required this.images,
    required this.height,
    this.width,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.showIndicators = true,
    this.showArrows = true,
    this.borderRadius,
  });

  @override
  State<EnhancedImageCarousel> createState() => _EnhancedImageCarouselState();
}

class _EnhancedImageCarouselState extends State<EnhancedImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.autoPlay && widget.images.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && widget.autoPlay) {
        final nextIndex = (_currentIndex + 1) % widget.images.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _prevImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Image carousel
        ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16.r),
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return ZoomableImage(
                  imageUrl: widget.images[index],
                  height: widget.height,
                  width: widget.width,
                  fit: BoxFit.cover,
                  gallery: widget.images,
                  initialIndex: index,
                );
              },
            ),
          ),
        ),

        // Navigation arrows
        if (widget.showArrows && widget.images.length > 1) ...[
          // Left arrow
          if (_currentIndex > 0)
            Positioned(
              left: 20.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrowButton(
                  Icons.arrow_back_ios,
                  onTap: _prevImage,
                  theme: theme,
                ),
              ),
            ),

          // Right arrow
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 20.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrowButton(
                  Icons.arrow_forward_ios,
                  onTap: _nextImage,
                  theme: theme,
                ),
              ),
            ),
        ],

        // Page indicators
        if (widget.showIndicators && widget.images.length > 1)
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: index == _currentIndex ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: index == _currentIndex
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _arrowButton(IconData icon, {required VoidCallback onTap, required ThemeData theme}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20.w,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
