import 'dart:html' as html;
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Upload payment screenshot and return download URL (Web-compatible)
  Future<String> uploadPaymentScreenshot(html.File file, String bookingId) async {
    try {
      print("📤 Starting upload for booking: $bookingId");
      print("📤 File info: ${file.name}, ${file.size} bytes, ${file.type}");
      
      // Create a unique filename
      final fileName = 'payment_${_uuid.v4()}_${file.name}';
      final storagePath = 'payment_screenshots/$bookingId/$fileName';
      
      print("📤 Storage path: $storagePath");
      
      // Create a reference to the file location
      final ref = _storage.ref().child(storagePath);
      
      // Convert html.File to bytes for upload
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      final bytes = reader.result as List<int>;
      
      print("📤 File converted to bytes: ${bytes.length} bytes");
      
      // Upload metadata
      final metadata = SettableMetadata(
        contentType: file.type,
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
      
      // Track upload progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print("📤 Upload progress: ${progress.toStringAsFixed(1)}%");
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {
        print("📤 Upload complete!");
      });
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("📤 Download URL obtained: ${downloadUrl.substring(0, 50)}...");
      
      return downloadUrl;
      
    } catch (e, stack) {
      print("❌ Upload failed: $e");
      print("❌ Stack trace: $stack");
      throw Exception('Failed to upload payment screenshot: $e');
    }
  }

  // Delete payment screenshot
  Future<void> deletePaymentScreenshot(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print("🗑️ Deleted screenshot: $imageUrl");
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
      print("⚠️ Could not calculate storage usage: $e");
      return 0;
    }
  }
}