import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/data/models/user_model.dart';
import 'package:internpath/domain/entities/user.dart';

class FirebaseUserService {
  final FirebaseFirestore _firestore;

  FirebaseUserService(this._firestore);

  CollectionReference get users => _firestore.collection('users');

  Future<UserModel?> getUserById(String id) async {
    final doc = await users.doc(id).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, id);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final docRef = users.doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    await docRef.update(data);
  }

  Future<void> createUser(String id, Map<String, dynamic> data) async {
    final docRef = users.doc(id);
    final doc = await docRef.get();
    if (doc.exists) {
      throw Exception('User already exists');
    }
    await docRef.set(data);
  }

  Future<void> deleteUser(String id) async {
    final docRef = users.doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    await docRef.delete();
  }

  Future<List<UserModel?>> getAllUsers({
    required String excludeUserId,
    int limit = 100,
    UserModel? lastUser,
  }) async {
    Query query = users.orderBy('createdAt', descending: true).limit(limit);

    if (lastUser != null) {
      query = query.startAfter([lastUser.createdAtMillis]);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
  }
}
