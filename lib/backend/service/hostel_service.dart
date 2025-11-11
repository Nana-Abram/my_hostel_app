import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';

class HostelService {
  final _db = FirebaseFirestore.instance;


  Future<void> addHostel(HostelModel hostel) async {
    await _db.collection('hostels').add(hostel.toMap());
  }


  Future<List<HostelModel>> getAllHostels() async {
    final snap = await _db.collection('hostels').get();
    return snap.docs
        .map((d) => HostelModel.fromMap(d.data(), d.id))
        .toList();
  }


  Stream<List<HostelModel>> watchAllHostels() {
    return _db.collection('hostels').snapshots().map(
      (QuerySnapshot snapshot) {
        return snapshot.docs.map((doc) {
          return HostelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      },
    );
  }


  Future<HostelModel?> getHostelById(String id) async {
    final doc = await _db.collection('hostels').doc(id).get();
    if (!doc.exists) return null;

    return HostelModel.fromMap(doc.data()!, doc.id);
  }
}
