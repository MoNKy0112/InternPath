import 'package:internpath/domain/entities/user.dart';
import 'package:internpath/domain/repositories/user_repository.dart';

class AuthUseCases {
  final UserRepository userRepository;

  AuthUseCases(this.userRepository);

  Future<User> signInWithEmailAndPassword(String email, String password) =>
      userRepository.signInWithEmailAndPassword(email, password);

  Future<User> registerWithEmailAndPassword(
    String fullName,
    String email,
    String password,
  ) => userRepository.registerWithEmailAndPassword(fullName, email, password);

  Future<void> signOut() => userRepository.signOut();

  Future<User?> getUserById(String userId) =>
      userRepository.getUserById(userId);

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      userRepository.updateProfile(uid, data);

  Future<void> sendPasswordResetEmail(String email) =>
      userRepository.sendPasswordResetEmail(email);

  Future<void> verifyEmail() => userRepository.verifyEmail();
}
