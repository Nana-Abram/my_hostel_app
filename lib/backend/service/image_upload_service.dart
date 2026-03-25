import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(Uint8List fileBytes, String fileName) async {
    try {
      // Consider adding timestamp to avoid filename conflicts
      final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final Reference ref = _storage.ref("hostel_images/$uniqueFileName");

      final UploadTask uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: "image/jpeg"),
      );

      // Wait for upload to complete
      await uploadTask;

      // Return download URL
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Optional: Add method for multiple image uploads
  Future<List<String>> uploadMultipleImages(List<Uint8List> fileBytesList, List<String> fileNames) async {
    try {
      final List<String> urls = [];
      
      for (int i = 0; i < fileBytesList.length; i++) {
        final String url = await uploadImage(fileBytesList[i], fileNames[i]);
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  /// Upload a video file to Firebase Storage and return its download URL
  Future<String> uploadVideo(Uint8List fileBytes, String fileName) async {
    return _uploadVideoToPath(fileBytes, fileName, 'hostel_videos');
  }

  /// Upload a room video to a separate room_videos/ folder
  Future<String> uploadRoomVideo(Uint8List fileBytes, String fileName) async {
    return _uploadVideoToPath(fileBytes, fileName, 'room_videos');
  }

  Future<String> _uploadVideoToPath(Uint8List fileBytes, String fileName, String folder) async {
    try {
      final String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final Reference ref = _storage.ref("$folder/$uniqueFileName");

      // Detect content type from extension
      final ext = fileName.split('.').last.toLowerCase();
      final contentType = switch (ext) {
        'mp4' => 'video/mp4',
        'mov' => 'video/quicktime',
        'avi' => 'video/x-msvideo',
        'mkv' => 'video/x-matroska',
        'webm' => 'video/webm',
        _ => 'video/mp4',
      };

      final UploadTask uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(contentType: contentType),
      );

      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  // Method to delete images if needed
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Future<void> deleteFileByUrl(String url) async {
  //   if (!url.contains('firebasestorage.googleapis.com')) return;

  //   final ref = _storage.refFromURL(url);
  //   await ref.delete();
  // }

}