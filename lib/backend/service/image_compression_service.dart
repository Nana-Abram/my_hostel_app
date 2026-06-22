import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Image compression utilities for optimizing images before upload
class ImageCompressionService {
  /// Compress an image file with quality and size constraints
  /// 
  /// [file] - The image file to compress
  /// [quality] - JPEG quality (0-100), default 85
  /// [maxWidth] - Maximum width in pixels, default 1920
  /// [maxHeight] - Maximum height in pixels, default 1080
  /// [format] - Target format (jpg, png, webp), default jpg
  static Future<File?> compressImage({
    required File file,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    try {
      // Get the file extension
      final String fileExtension = path.extension(file.path).toLowerCase();
      
      // Skip compression for unsupported formats
      if (!_isSupportedFormat(fileExtension)) {
        debugPrint('Unsupported format: $fileExtension');
        return file;
      }

      // Generate output path
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}${_getExtension(format)}',
      );

      // Compress the image
      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: format,
      );

      if (compressedFile == null) {
        debugPrint('Failed to compress image');
        return file;
      }

      final File compressed = File(compressedFile.path);
      
      // Compare file sizes
      final int originalSize = await file.length();
      final int compressedSize = await compressed.length();
      final double reduction = ((originalSize - compressedSize) / originalSize * 100);
      
      debugPrint('Image compressed: ${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)} (${reduction.toStringAsFixed(1)}% reduction)');

      // Return compressed file if it's smaller, otherwise return original
      return compressedSize < originalSize ? compressed : file;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return file;
    }
  }

  /// Compress an image from Uint8List (for web platform)
  static Future<Uint8List> compressImageFromBytes({
    required Uint8List bytes,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: format,
      );

      final int originalSize = bytes.length;
      final int compressedSize = compressed.length;
      final double reduction = ((originalSize - compressedSize) / originalSize * 100);
      
      debugPrint('Image compressed: ${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)} (${reduction.toStringAsFixed(1)}% reduction)');

      return compressedSize < originalSize ? compressed : bytes;
    } catch (e) {
      debugPrint('Error compressing image from bytes: $e');
      return bytes;
    }
  }

  /// Compress multiple images
  static Future<List<File>> compressMultipleImages({
    required List<File> files,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
    CompressFormat format = CompressFormat.jpeg,
    void Function(int current, int total)? onProgress,
  }) async {
    final List<File> compressedFiles = [];
    
    for (int i = 0; i < files.length; i++) {
      onProgress?.call(i + 1, files.length);
      
      final File? compressed = await compressImage(
        file: files[i],
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        format: format,
      );
      
      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }
    
    return compressedFiles;
  }

  /// Get image compression presets for different use cases
  static ImageCompressionPreset getPreset(CompressionPresetType type) {
    switch (type) {
      case CompressionPresetType.thumbnail:
        return const ImageCompressionPreset(
          quality: 70,
          maxWidth: 400,
          maxHeight: 400,
          format: CompressFormat.jpeg,
        );
      
      case CompressionPresetType.medium:
        return const ImageCompressionPreset(
          quality: 80,
          maxWidth: 1024,
          maxHeight: 1024,
          format: CompressFormat.jpeg,
        );
      
      case CompressionPresetType.high:
        return const ImageCompressionPreset(
          quality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
          format: CompressFormat.jpeg,
        );
      
      case CompressionPresetType.original:
        return const ImageCompressionPreset(
          quality: 95,
          maxWidth: 4096,
          maxHeight: 4096,
          format: CompressFormat.jpeg,
        );
    }
  }

  /// Check if file format is supported for compression
  static bool _isSupportedFormat(String extension) {
    const List<String> supportedFormats = ['.jpg', '.jpeg', '.png', '.webp', '.heic'];
    return supportedFormats.contains(extension.toLowerCase());
  }

  /// Get file extension for compression format
  static String _getExtension(CompressFormat format) {
    switch (format) {
      case CompressFormat.jpeg:
        return '.jpg';
      case CompressFormat.png:
        return '.png';
      case CompressFormat.webp:
        return '.webp';
      case CompressFormat.heic:
        return '.heic';
    }
  }

  /// Format bytes to human-readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Compression preset configuration
class ImageCompressionPreset {
  final int quality;
  final int maxWidth;
  final int maxHeight;
  final CompressFormat format;

  const ImageCompressionPreset({
    required this.quality,
    required this.maxWidth,
    required this.maxHeight,
    required this.format,
  });
}

/// Predefined compression preset types
enum CompressionPresetType {
  thumbnail,  // 400x400, quality 70
  medium,     // 1024x1024, quality 80
  high,       // 1920x1080, quality 85
  original,   // 4096x4096, quality 95
}
