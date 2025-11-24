import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:internpath/data/firebase/firebase_auth_service.dart';
import 'package:internpath/data/firebase/firebase_user_service.dart';
import 'package:internpath/data/models/user_model.dart';
import 'package:internpath/domain/entities/user.dart';
import 'package:internpath/domain/entities/user_role.dart';
import 'package:internpath/domain/repositories/user_repository.dart';
import 'package:internpath/utils/validators.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthService _authService;
  final FirebaseUserService _userService;

  UserRepositoryImpl(this._authService, this._userService);

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final fb.UserCredential cred = await _authService
        .signInWithEmailAndPassword(email, password);

    final uid = cred.user!.uid;
    final user = await _userService.getUserById(uid);
    if (user == null) throw Exception('User not found');
    return user.toEntity();
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
      role: UserRole.user,
      photoUrl: null,
      createdAtMillis: DateTime.now(),
      updatedAtMillis: DateTime.now(),
    );
    await _userService.createUser(uid, model.toMap());
    return model.toEntity();
  }

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<User?> getUserById(String userId) async {
    final doc = await _userService.getUserById(userId);
    return doc?.toEntity();
  }

  @override
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    final allowedFields = {'fullName', 'photoUrl'};
    final safeData = filterAllowedFields(data, allowedFields);
    await _userService.updateUser(uid, safeData);
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
}
