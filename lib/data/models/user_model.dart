import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/domain/entities/user.dart';
import 'package:internpath/domain/entities/user_role.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAtMillis;
  final DateTime updatedAtMillis;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.photoUrl,
    required this.createdAtMillis,
    required this.updatedAtMillis,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      photoUrl: map['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role'] ?? 'user'}',
        orElse: () => UserRole.user,
      ),
      createdAtMillis:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAtMillis:
          (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'fullName': fullName,
    'photoUrl': photoUrl,
    'role': role.toString().split('.').last,
    'createdAt': createdAtMillis,
    'updatedAt': updatedAtMillis,
  };

  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      photoUrl: photoUrl,
      role: UserRole.user, // Default role; adjust as necessary
      createdAt: createdAtMillis,
      updatedAt: updatedAtMillis,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      role: user.role,
      photoUrl: user.photoUrl,
      createdAtMillis: user.createdAt,
      updatedAtMillis: user.updatedAt,
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
