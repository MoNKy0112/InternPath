import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/domain/entities/company.dart';

class CompanyModel extends Company {
  CompanyModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.description,
    super.website,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> data, String id) {
    return CompanyModel(
      id: id,
      name: data['name'],
      logoUrl: data['logoUrl'],
      description: data['description'],
      website: data['website'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "logoUrl": logoUrl,
      "description": description,
      "website": website,
    };
  }

  factory CompanyModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CompanyModel(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
      description: data['description'],
      website: data['website'],
    );
  }

  factory CompanyModel.fromEntity(Company company) {
    return CompanyModel(
      id: company.id,
      name: company.name,
      logoUrl: company.logoUrl,
      description: company.description,
      website: company.website,
    );
  }

  Company toEntity() {
    return Company(
      id: id,
      name: name,
      logoUrl: logoUrl,
      description: description,
      website: website,
    );
  }
}
