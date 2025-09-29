import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:internpath/data/firebase/firebase_auth_service.dart';
import 'package:internpath/data/models/user_model.dart';
import 'package:internpath/domain/entities/user.dart';
import 'package:internpath/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthService _authService;
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._authService, this._firestore);

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final fb.UserCredential cred = await _authService
        .signInWithEmailAndPassword(email, password);

    final uid = cred.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    final model = UserModel.fromMap(doc.data() ?? {}, uid);
    return model.toEntity();
  }

  @override
  Future<User> registerWithEmailAndPassword(
    String fullName,
    String email,
    String password,
  ) async {
    final fb.UserCredential cred = await _authService
        .registerWithEmailAndPassword(email, password);

    final uid = cred.user!.uid;
    final model = UserModel(
      id: uid,
      email: email,
      fullName: fullName,
      photoUrl: null,
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _firestore.collection('users').doc(uid).set(model.toMap());
    return model.toEntity();
  }

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<User?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    final model = UserModel.fromMap(doc.data()!, userId);
    return model.toEntity();
  }

  @override
  Future<void> updateProfile(User user) async {
    final model = UserModel.fromEntity(user);
    await _firestore.collection('users').doc(user.id).set(model.toMap());
  }

  @override
  User? getCurrentUser() {
    final fb.User? fbUser = _authService.currentUser;
    if (fbUser == null) return null;
    return getUserById(fbUser.uid) as User?;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  @override
  Future<void> verifyEmail() {
    return _authService.verifyEmail();
  }

  Future<bool> isExistingEmail(String email) async {
    final methods = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return methods.docs.isNotEmpty;
  }
}
