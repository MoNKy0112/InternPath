class User {
  final String id;
  final String fullName;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.photoUrl,
  });
}
