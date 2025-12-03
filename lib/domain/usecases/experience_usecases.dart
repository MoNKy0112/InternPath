import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/repositories/experience_repository.dart';

class ExperienceUseCases {
  final ExperienceRepository experienceRepository;

  ExperienceUseCases(this.experienceRepository);

  Future<String> addExperience(String userId, Experience experience) =>
      experienceRepository.addExperience(userId, experience);

  Future<void> updateExperience(
    String userId,
    String experienceId,
    Experience experience,
  ) => experienceRepository.updateExperience(userId, experienceId, experience);

  Future<void> deleteExperience(String userId, String experienceId) =>
      experienceRepository.deleteExperience(userId, experienceId);

  Future<List<Experience>> getExperiencesByUserId(
    String userId, {
    int limit = 10,
    Experience? lastExperience,
  }) => experienceRepository.getExperiencesByUserId(
    userId,
    limit: limit,
    lastExperience: lastExperience,
  );

  Future<Experience?> getExperienceById(String experienceId) =>
      experienceRepository.getExperienceById(experienceId);

  Future<List<Experience>> getAllExperiences({
    required String excludeUserId,
    int limit = 10,
    Experience? lastExperience,
  }) => experienceRepository.getAllExperiences(
    excludeUserId: excludeUserId,
    limit: limit,
    lastExperience: lastExperience,
  );

  Future<List<Experience>> searchExperiences(
    String userId,
    String query, {
    int limit = 50,
  }) => experienceRepository.searchExperiences(userId, query, limit: limit);

  Future<List<Experience>> getExperiencesByCompanyId(
    String companyId, {
    int limit = 10,
    Experience? lastExperience,
  }) => experienceRepository.getExperiencesByCompanyId(
    companyId,
    limit: limit,
    lastExperience: lastExperience,
  );
}
