// import 'dart:html' as html;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:my_hostel_app/backend/model/hostel_model.dart';
// import 'image_upload_service.dart';

// class HostelService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late final ImageUploadService _imageUploadService = ImageUploadService();


//  Future<String> addHostelWithImages(HostelModel hostel, List<XFile> imageFiles) async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) throw Exception('User not authenticated');

//       final hostelData = hostel.toMap();
//       hostelData['ownerId'] = userId;
//       hostelData['createdAt'] = FieldValue.serverTimestamp();
//       hostelData['updatedAt'] = FieldValue.serverTimestamp();
//       hostelData['rating'] = 0.0;
//       hostelData['reviewsCount'] = 0.0;
//       hostelData['status'] = 'pending';

//       final docRef = await _firestore.collection('hostels').add(hostelData);
//       final hostelId = docRef.id;

//       if (imageFiles.isNotEmpty) {
//         List<html.File> htmlFiles = [];

//         for (XFile xfile in imageFiles) {
//           html.File htmlFile = await _imageUploadService.xFileToHtmlFile(xfile);
//           htmlFiles.add(htmlFile);
//         }

//         final imageUrls = await _imageUploadService.uploadMultipleImages(htmlFiles, hostelId);

//         await _firestore.collection('hostels').doc(hostelId).update({
//           'images': imageUrls,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//       }

//       return hostelId;
//     } catch (e) {
//       throw Exception('Error adding hostel: $e');
//     }
//   }

//  // Get all hostels owned by current user
//   Stream<List<HostelModel>> getMyHostels() {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) {
//       return Stream.value([]);
//     }

//     return _firestore
//         .collection('hostels')
//         .where('ownerId', isEqualTo: userId)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => HostelModel.fromMap(doc.data(), doc.id))
//             .toList());
//   }

//   // Get single hostel by ID
//   Future<HostelModel?> getHostelById(String hostelId) async {
//     try {
//       final doc = await _firestore.collection('hostels').doc(hostelId).get();
//       if (doc.exists) {
//         return HostelModel.fromMap(doc.data()!, doc.id);
//       }
//       return null;
//     } catch (e) {
//       throw Exception('Error fetching hostel: $e');
//     }
//   }

  

//   // Update hostel
//   Future<void> updateHostel(String hostelId, HostelModel hostel) async {
//     try {
//       final hostelData = hostel.toMap();
//       hostelData['updatedAt'] = FieldValue.serverTimestamp();

//       await _firestore.collection('hostels').doc(hostelId).update(hostelData);
//     } catch (e) {
//       throw Exception('Error updating hostel: $e');
//     }
//   }

//   // Delete hostel
//   Future<void> deleteHostel(String hostelId) async {
//     try {
//       await _firestore.collection('hostels').doc(hostelId).delete();
//     } catch (e) {
//       throw Exception('Error deleting hostel: $e');
//     }
//   }

//   // Update hostel status
//   Future<void> updateHostelStatus(String hostelId, String status) async {
//     try {
//       await _firestore.collection('hostels').doc(hostelId).update({
//         'status': status,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       throw Exception('Error updating hostel status: $e');
//     }
//   }
 
// }