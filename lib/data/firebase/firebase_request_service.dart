import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRequestService {
  final _collection = FirebaseFirestore.instance.collection('requests');

  Future<void> create(Map<String, dynamic> data) async {
    await _collection.add(data);
  }

  Future<DocumentSnapshot> getById(String requestId) {
    return _collection.doc(requestId).get();
  }

  Future<QuerySnapshot> getByUser(String userId) {
    return _collection.where('userId', isEqualTo: userId).get();
  }

  Future<QuerySnapshot> getPending() {
    return _collection.where('status', isEqualTo: 'pending').get();
  }

  Future<void> updateStatus(String requestId, Map<String, dynamic> data) {
    return _collection.doc(requestId).update(data);
  }
}
