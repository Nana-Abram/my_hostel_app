import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Upload payment screenshot and return download URL.
  Future<String> uploadPaymentScreenshot(XFile file, String bookingId) async {
    try {
      // Create a unique filename
      final fileName = 'payment_${_uuid.v4()}_${file.name}';
      final storagePath = 'payment_screenshots/$bookingId/$fileName';

      // Create a reference to the file location
      final ref = _storage.ref().child(storagePath);

      // Convert XFile to bytes for upload on all supported platforms.
      final bytes = await file.readAsBytes();
      
      // Upload metadata
      final metadata = SettableMetadata(
        contentType: _detectContentType(file.name),
        customMetadata: {
          'originalName': file.name,
          'uploadedBy': bookingId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Upload the file
      final uploadTask = ref.putData(
        Uint8List.fromList(bytes),
        metadata,
      );

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;

    } catch (e) {
      throw Exception('Failed to upload payment screenshot: $e');
    }
  }

  // Delete payment screenshot
  Future<void> deletePaymentScreenshot(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete payment screenshot: $e');
    }
  }
  
  // Get storage usage (optional)
  Future<int> getStorageUsage(String userId) async {
    try {
      final listResult = await _storage.ref('payment_screenshots').listAll();
      int totalSize = 0;
      
      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  String _detectContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}