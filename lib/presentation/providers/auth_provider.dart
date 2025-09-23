import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthProvider extends ChangeNotifier {
  fb.User? _firebaseUser;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  AuthProvider() {
    // Escucha los cambios en el estado de autenticación
    _auth.authStateChanges().listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });
  }

  fb.User? get currentUser => _firebaseUser ?? _auth.currentUser;

  bool get isLoggedIn => _firebaseUser != null;
}
