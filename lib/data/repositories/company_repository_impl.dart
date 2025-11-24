import 'package:internpath/data/firebase/firebase_company_service.dart';
import 'package:internpath/data/models/company_model.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final FirebaseCompanyService _firebaseService;

  CompanyRepositoryImpl(this._firebaseService);

  @override
  Future<Company?> getCompanyById(String id) async {
    final data = await _firebaseService.getById(id);
    if (data == null) return null;
    return data.toEntity();
  }

  @override
  Future<List<Company>> getAllCompanies(
    String? searchTerm,
    String? sortBy, {
    int limit = 10,
    Company? lastCompany,
  }) async {
    final dataList = await _firebaseService.getAllCompanies(
      searchTerm,
      sortBy,
      limit: limit,
      lastCompany: lastCompany != null
          ? CompanyModel.fromEntity(lastCompany)
          : null,
    );
    return dataList.map((data) => data.toEntity()).toList();
  }

  @override
  Future<void> addCompany(Company company) async {
    final model = CompanyModel.fromEntity(company);
    await _firebaseService.addCompany(model);
  }

  @override
  Future<void> updateCompany(String id, Company company) async {
    final model = CompanyModel.fromEntity(company);
    await _firebaseService.updateCompany(id, model.toMap());
  }

  @override
  Future<void> deleteCompany(String id) async {
    await _firebaseService.deleteCompany(id);
  }
}
