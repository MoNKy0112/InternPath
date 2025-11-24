class Company {
  final String id;
  final String name;
  final String? logoUrl;
  final String? description;
  final String? website;

  Company({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    this.website,
  });
}
