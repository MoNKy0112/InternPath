import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/data/models/company_model.dart';

class FirebaseCompanyService {
  final FirebaseFirestore _firestore;

  FirebaseCompanyService(this._firestore);

  Future<String> addCompany(CompanyModel company) async {
    final docRef = await _firestore
        .collection('companies')
        .add(company.toMap());
    return docRef.id;
  }

  Future<void> updateCompany(String id, Map<String, dynamic> data) async {
    final docRef = _firestore.collection('companies').doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('Company not found');
    }
    await docRef.update(data);
  }

  Future<void> deleteCompany(String id) async {
    await _firestore.collection('companies').doc(id).delete();
  }

  Future<List<CompanyModel>> getAllCompanies(
    String? searchTerm,
    String? sortBy,
    int? limit,
    CompanyModel? lastCompany,
  ) {
    Query query = _firestore.collection('companies');
    if (limit != null) {
      query = query.limit(limit);
    }

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff');
    }

    if (sortBy != null) {
      query = query.orderBy(sortBy);
    }

    if (lastCompany != null) {
      query = query.startAfter([lastCompany.name]);
    }

    return query.get().then((snapshot) {
      return snapshot.docs
          .map((doc) => CompanyModel.fromDocument(doc))
          .toList();
    });
  }

  Future<CompanyModel?> getById(String id) async {
    final doc = await _firestore.collection('companies').doc(id).get();
    if (!doc.exists) return null;
    return CompanyModel.fromDocument(doc);
  }
}
