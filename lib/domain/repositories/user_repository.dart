import 'package:internpath/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> registerWithEmailAndPassword(
    String fullName,
    String email,
    String password,
  );
  Future<void> signOut();
  User? getCurrentUser();
  Future<User?> getUserById(String userId);
  Future<void> updateProfile(String uid, Map<String, dynamic> data);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> verifyEmail();
}
