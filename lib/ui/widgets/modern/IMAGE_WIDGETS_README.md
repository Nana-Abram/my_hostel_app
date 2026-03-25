# Image Enhancement Components

This module provides advanced image handling components with caching, progressive loading, zoom, and compression features.

## Components

### 1. EnhancedCachedImage
Progressive image loading with shimmer effects and error handling.

```dart
EnhancedCachedImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 300.w,
  height: 200.h,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(12.r),
  showShimmer: true, // Shows shimmer while loading
)
```

**Features:**
- Automatic caching with `cached_network_image`
- Shimmer loading placeholder
- Fade-in/fade-out animations
- Error state with retry
- Custom placeholder and error widgets

---

### 2. ZoomableImage
Tappable image that opens in full-screen viewer with pinch-to-zoom.

```dart
ZoomableImage(
  imageUrl: 'https://example.com/image.jpg',
  width: 300.w,
  height: 200.h,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(12.r),
  // Optional: provide gallery for swiping between images
  gallery: [image1, image2, image3],
  initialIndex: 0,
)
```

**Features:**
- Hero animation to full-screen
- Pinch-to-zoom (0.5x to 4x)
- Swipe between images in gallery mode
- Navigation arrows for desktop/web

---

### 3. ImageLightbox
Full-screen image viewer with gesture controls.

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ImageLightbox(
      images: ['url1', 'url2', 'url3'],
      initialIndex: 0,
    ),
  ),
);
```

**Features:**
- Pinch-to-zoom and pan
- Swipe navigation between images
- Image counter (1/10)
- Page indicators
- Navigation arrows
- Close button

---

### 4. LazyImageGrid
Grid view with lazy loading for optimal performance.

```dart
LazyImageGrid(
  imageUrls: hostel.images,
  crossAxisCount: 3,
  aspectRatio: 1.0,
  spacing: 8.0,
  onImageTap: (index) {
    // Handle tap
  },
)
```

**Features:**
- Lazy loads images as they scroll into view
- Opens in full-screen viewer on tap
- Configurable grid layout
- Optimized for large image lists

---

### 5. EnhancedImageCarousel
Advanced carousel with auto-play and indicators.

```dart
EnhancedImageCarousel(
  images: hostel.images,
  height: 400.h,
  width: 0.95.sw,
  autoPlay: true,
  autoPlayInterval: Duration(seconds: 5),
  showIndicators: true,
  showArrows: true,
  borderRadius: BorderRadius.circular(16.r),
)
```

**Features:**
- Auto-play with configurable interval
- Page indicators (dots)
- Navigation arrows
- Tap to open full-screen
- Smooth animations

---

## Image Compression Service

Compress images before upload to save bandwidth and storage.

```dart
// Compress a single image
final File? compressed = await ImageCompressionService.compressImage(
  file: imageFile,
  quality: 85,
  maxWidth: 1920,
  maxHeight: 1080,
  format: CompressFormat.jpeg,
);

// Compress multiple images with progress
final List<File> compressed = await ImageCompressionService.compressMultipleImages(
  files: imageFiles,
  quality: 85,
  maxWidth: 1920,
  maxHeight: 1080,
  onProgress: (current, total) {
    print('Compressing $current of $total');
  },
);

// Use compression presets
final preset = ImageCompressionService.getPreset(CompressionPresetType.high);
final compressed = await ImageCompressionService.compressImage(
  file: imageFile,
  quality: preset.quality,
  maxWidth: preset.maxWidth,
  maxHeight: preset.maxHeight,
  format: preset.format,
);
```

### Compression Presets
- **Thumbnail**: 400x400, 70% quality - for profile pictures, icons
- **Medium**: 1024x1024, 80% quality - for gallery thumbnails
- **High**: 1920x1080, 85% quality - for full-size display images
- **Original**: 4096x4096, 95% quality - minimal compression

### For Web Platform
```dart
// Compress from bytes (web)
final Uint8List compressed = await ImageCompressionService.compressImageFromBytes(
  bytes: imageBytes,
  quality: 85,
  maxWidth: 1920,
  maxHeight: 1080,
);
```

---

## Migration Guide

### Before (using image_network):
```dart
ImageNetwork(
  image: imageUrl,
  height: 300.h,
  width: 0.25.sw,
  fitAndroidIos: BoxFit.cover,
  fitWeb: BoxFitWeb.cover,
  onLoading: CircularProgressIndicator(),
  onError: Icon(Icons.error),
)
```

### After (using EnhancedCachedImage):
```dart
EnhancedCachedImage(
  imageUrl: imageUrl,
  height: 300.h,
  width: 0.25.sw,
  fit: BoxFit.cover,
  showShimmer: true, // Better loading UX
)
```

---

## Best Practices

1. **Use appropriate compression preset** based on image usage
2. **Enable shimmer loading** for better perceived performance
3. **Provide gallery context** for ZoomableImage when showing multiple images
4. **Use LazyImageGrid** for large lists to optimize memory
5. **Compress images before upload** to reduce bandwidth usage
6. **Set reasonable dimensions** - don't load 4K images for 200px thumbnails

---

## Performance Tips

- **Caching**: All images are cached automatically by `cached_network_image`
- **Memory**: Large images are automatically downsampled to fit the widget size
- **Network**: Images are loaded progressively showing low-res first
- **Compression**: Reduces file sizes by 40-70% with minimal quality loss

---

## Dependencies

```yaml
dependencies:
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  flutter_screenutil: ^5.9.3
  flutter_image_compress: ^2.3.0
  path_provider: ^2.1.5
  path: ^1.9.0
```
