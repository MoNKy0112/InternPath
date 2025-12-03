import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/repositories/company_repository.dart';

class CompanyUseCases {
  final CompanyRepository companyRepository;

  CompanyUseCases(this.companyRepository);

  Future<Company?> getCompanyById(String companyId) =>
      companyRepository.getCompanyById(companyId);

  Future<List<Company>> getCompanies({
    String? searchTerm,
    String? sortBy,
    int? limit,
    Company? lastCompany,
  }) =>
      companyRepository.getAllCompanies(searchTerm, sortBy, limit, lastCompany);

  Future<String> addCompany(Company company) =>
      companyRepository.addCompany(company);

  Future<void> updateCompany(String companyId, Company company) =>
      companyRepository.updateCompany(companyId, company);

  Future<void> deleteCompany(String companyId) =>
      companyRepository.deleteCompany(companyId);
}
