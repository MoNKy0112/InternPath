import 'package:firebase_auth/firebase_auth.dart' as fb;

class FirebaseAuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<fb.UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<fb.UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  fb.User? get currentUser => _auth.currentUser;
}
