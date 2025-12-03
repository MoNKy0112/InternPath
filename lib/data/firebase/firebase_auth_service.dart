import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';

class FirebaseAuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<fb.UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // registro normal: crea usuario EN LA APP PRINCIPAL -> inicia sesión automáticamente
  Future<fb.UserCredential> registerAndSignIn(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // registro por admin: crea usuario SIN tocar la sesión actual, usando app secundaria
  Future<fb.UserCredential> registerWithoutSignIn(
    String email,
    String password,
  ) async {
    FirebaseApp? secondaryApp;
    try {
      final FirebaseApp defaultApp = Firebase.app();
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary-${DateTime.now().millisecondsSinceEpoch}',
        options: defaultApp.options,
      );
      final fb.FirebaseAuth secondaryAuth = fb.FirebaseAuth.instanceFor(
        app: secondaryApp,
      );
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // NOTA: crear el documento de perfil (dominio) usando credential.user!.uid
      // Hacerlo antes de cerrar sesión en secondaryAuth; si falla, puedes eliminar el usuario
      // con secondaryAuth.currentUser?.delete() como rollback.

      // cerrar y limpiar app secundaria
      try {
        await secondaryAuth.signOut();
      } catch (_) {}
      try {
        await secondaryApp.delete();
      } catch (_) {}

      return credential;
    } catch (e) {
      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> verifyEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  fb.User? get currentUser => _auth.currentUser;
}
