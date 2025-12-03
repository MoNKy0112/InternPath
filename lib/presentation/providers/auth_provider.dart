import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/domain/entities/user.dart';
import 'package:internpath/domain/entities/user_role.dart';

class AuthProvider extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final AuthUseCases _authUseCases;

  fb.User? _firebaseUser;
  User? domainUser;
  bool isLoadingDomainUser = false;
  String? domainError;

  AuthProvider(this._authUseCases) {
    // escuchar cambios de firebase auth
    _auth.authStateChanges().listen(_onAuthChanged);
    // opcional: inicializar con currentUser inmediato
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) _loadDomainUser(_firebaseUser!.uid);
  }

  fb.User? get currentUser => _firebaseUser ?? _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  bool get isModder => domainUser?.role == UserRole.modder;
  bool get isAdmin => domainUser?.role == UserRole.admin;
  bool get domainUserData => domainUser != null;

  Future<void> _onAuthChanged(fb.User? user) async {
    _firebaseUser = user;
    domainUser = null;
    domainError = null;
    notifyListeners();
    if (user != null) {
      await _loadDomainUser(user.uid);
    }
  }

  Future<void> _loadDomainUser(String uid) async {
    isLoadingDomainUser = true;
    domainError = null;
    notifyListeners();
    try {
      final u = await _authUseCases.getUserById(uid);
      domainUser = u;
      print('Domain user loaded: ${u}');
    } catch (e) {
      domainError = e.toString();
    } finally {
      isLoadingDomainUser = false;
      notifyListeners();
    }
  }

  // Exponer método público para forzar refresh (ej: pull-to-refresh de perfil)
  Future<void> refreshDomainUser() async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _loadDomainUser(uid);
  }

  // Llamar al deslogueo desde aquí para limpiar cache
  Future<void> signOut() async {
    domainUser = null;
    domainError = null;
    notifyListeners();
    await _auth.signOut();
  }
}
