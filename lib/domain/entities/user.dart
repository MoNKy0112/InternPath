import 'package:internpath/domain/entities/user_role.dart';

class User {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? photoUrl;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
  });
}
