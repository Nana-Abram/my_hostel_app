import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';

class HostelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to real-time updates + local cache
  Stream<List<HostelModel>> getAllHostelsStream() {
    return _firestore
        .collection('hostels')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) => snapshot.docs
            .map((doc) => HostelModel.fromMap(doc.data(), doc.id))
            .toList());
  }
    // Get hostels by owner
  Stream<List<HostelModel>> getHostelsByOwner(String ownerId) {
    return _firestore
        .collection('hostels')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HostelModel.fromMap(doc.data(), doc.id))
            .toList());
  }

Stream<HostelModel?> getHostelByIdStream(String id) {
  return _firestore
      .collection('hostels')
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? HostelModel.fromMap(doc.data()!, doc.id) : null);
}

// add hostel
  Future<void> addHostel(HostelModel hostel) async {
    try {
      await _firestore.collection('hostels').add(hostel.toMap());
    } catch (e) {
      throw Exception('Failed to add hostel: $e');
    }
  }



  // Fetch once (from cache first)
  Future<List<HostelModel>> getAllHostels() async {
    try {
      final querySnapshot = await _firestore
          .collection('hostels')
          .get(const GetOptions(source: Source.cache))
          .catchError((_) async {
        return await _firestore.collection('hostels').get();
      });

      return querySnapshot.docs
          .map((doc) => HostelModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch hostels: $e');
    }
  }

  // Get a single hostel (cached first)
  Future<HostelModel?> getHostelById(String id) async {
    try {
      final doc = await _firestore
          .collection('hostels')
          .doc(id)
          .get(const GetOptions(source: Source.cache))
          .catchError((_) async {
        return await _firestore.collection('hostels').doc(id).get();
      });

      return doc.exists ? HostelModel.fromMap(doc.data()!, doc.id) : null;
    } catch (e) {
      throw Exception('Failed to fetch hostel: $e');
    }
  }

  // Update hostel
  Future<void> updateHostel(String id, HostelModel hostel) async {
    try {
      await _firestore.collection('hostels').doc(id).update(hostel.toMap());
    } catch (e) {
      throw Exception('Failed to update hostel: $e');
    }
  }

Future<void> deleteHostel(String id) async {
  try {
    print('🔴 [DELETE START] Deleting hostel with ID: $id');
    
    if (id.isEmpty) {
      throw Exception('Hostel ID cannot be empty');
    }
    
    // Check if document exists before deleting
    final doc = await _firestore.collection('hostels').doc(id).get();
    print('📄 Document exists: ${doc.exists}');
    
    if (!doc.exists) {
      throw Exception('Hostel with ID $id does not exist');
    }
    
    print('🗑️ Proceeding with deletion...');
    await _firestore.collection('hostels').doc(id).delete();
    print('✅ [DELETE SUCCESS] Hostel deleted successfully');
    
  } catch (e) {
    print('❌ [DELETE ERROR] Delete hostel error: $e');
    throw Exception('Failed to delete hostel: $e');
  }
}
    // Optional: Add hostel with custom ID if needed
  Future<void> addHostelWithId(String id, HostelModel hostel) async {
    try {
      await _firestore.collection('hostels').doc(id).set(hostel.toMap());
    } catch (e) {
      throw Exception('Failed to add hostel with ID: $e');
    }
  }


}