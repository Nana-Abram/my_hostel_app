import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  final storage = FirebaseStorage.instance;

  Future<String> uploadImage(Uint8List fileBytes, String fileName) async {
    final ref = storage.ref("hostel_images/$fileName");

    await ref.putData(
      fileBytes,
      SettableMetadata(contentType: "image/jpeg"),
    );

    return await ref.getDownloadURL();
  }
}
