import 'package:internpath/domain/entities/company.dart';

abstract class CompanyRepository {
  Future<Company?> getCompanyById(String companyId);
  Future<List<Company>> getAllCompanies(
    String? searchTerm,
    String? sortBy,
    int? limit,
    Company? lastCompany,
  );
  Future<void> addCompany(Company company);
  Future<void> updateCompany(String companyId, Company company);
  Future<void> deleteCompany(String companyId);
}
