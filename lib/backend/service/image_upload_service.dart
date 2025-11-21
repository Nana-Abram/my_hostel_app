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

  // Optional: Add method to delete images if needed
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}