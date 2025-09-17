import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/data/models/experience_model.dart';

class FirebaseExperienceService {
  final FirebaseFirestore _firestore;

  FirebaseExperienceService(this._firestore);

  CollectionReference get _experiences => _firestore.collection('experiences');

  Future<ExperienceModel?> getById(String id) async {
    final doc = await _experiences.doc(id).get();
    if (!doc.exists) return null;
    return ExperienceModel.fromDocument(doc);
  }

  Future<List<ExperienceModel>> getByUserId(String userId) async {
    final querySnapshot = await _experiences
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs
        .map((doc) => ExperienceModel.fromDocument(doc))
        .toList();
  }

  Future<void> create(String userId, Map<String, dynamic> data) async {
    await _experiences.add({'userId': userId, ...data});
  }

  Future<void> update(
    String userId,
    String experienceId,
    Map<String, dynamic> data,
  ) async {
    final docRef = _experiences.doc(experienceId);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('Experience not found');
    }
    if (doc.get('userId') != userId) {
      throw Exception('Unauthorized');
    }
    await docRef.update(data);
  }

  Future<void> delete(String userId, String experienceId) async {
    final docRef = _experiences.doc(experienceId);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('Experience not found');
    }
    if (doc.get('userId') != userId) {
      throw Exception('Unauthorized');
    }
    await docRef.delete();
  }

  Future<List<ExperienceModel>> getAllExperiences({
    required String excludeUserId,
    int limit = 10,
    ExperienceModel? lastExperience,
  }) async {
    Query query = _firestore
        .collection('experiences')
        .where('userId', isNotEqualTo: excludeUserId)
        .orderBy('startDate', descending: true)
        .limit(limit);

    if (lastExperience != null) {
      query = query.startAfter([lastExperience.startDate]);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ExperienceModel.fromDocument(doc))
        .toList();
  }
}
