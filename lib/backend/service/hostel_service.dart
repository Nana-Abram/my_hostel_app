import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';

class HostelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to real-time updates + local cache
  Stream<List<HostelModel>> getAllHostelsStream() {
         
      return _firestore.collection('hostels').snapshots(includeMetadataChanges: true)
  .map((snapshot) {
    print("🔥 Hostels snapshot size: ${snapshot.docs.length}");
    print("📦 Data from cache? ${snapshot.metadata.isFromCache}");
    return snapshot.docs.map((doc) => HostelModel.fromMap(doc.data(),doc.id)).toList();
  });

  }

  Future<void> addHostel(HostelModel hostel) async {
    await _firestore.collection('hostels').add(hostel.toMap());
  }

  // Fetch once (from cache first)
  Future<List<HostelModel>> getAllHostels() async {
    final querySnapshot = await _firestore.collection('hostels').get(
      
      const GetOptions(source: Source.cache), // <– first try local cache
    ).catchError((_) async {
      // fallback to server if cache empty
      return await _firestore.collection('hostels').get();
    });

    return querySnapshot.docs.map((doc) => HostelModel.fromMap(doc.data(),doc.id)).toList();
  }

  // Get a single hostel (cached first)
  Future<HostelModel?> getHostelById(String id) async {
    final doc = await _firestore.collection('hostels').doc(id).get(
      const GetOptions(source: Source.cache),
    ).catchError((_) async {
      return await _firestore.collection('hostels').doc(id).get();
    });

    return doc.exists ? HostelModel.fromMap(doc.data()!,doc.id) : null;
  }
}
