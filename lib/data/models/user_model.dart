import 'package:internpath/domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? photoUrl;
  final int createdAtMillis;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.photoUrl,
    required this.createdAtMillis,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      photoUrl: map['photoUrl'] as String?,
      createdAtMillis:
          (map['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'fullName': fullName,
    'photoUrl': photoUrl,
    'createdAt': createdAtMillis,
  };

  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      photoUrl: photoUrl,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      photoUrl: user.photoUrl,
      createdAtMillis: user.createdAt.millisecondsSinceEpoch,
    );
  }
}
