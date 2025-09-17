import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/repositories/experience_repository.dart';

class ExperienceUseCases {
  final ExperienceRepository experienceRepository;

  ExperienceUseCases(this.experienceRepository);

  Future<void> addExperience(String userId, Experience experience) =>
      experienceRepository.addExperience(userId, experience);

  Future<void> updateExperience(
    String userId,
    String experienceId,
    Experience experience,
  ) => experienceRepository.updateExperience(userId, experienceId, experience);

  Future<void> deleteExperience(String userId, String experienceId) =>
      experienceRepository.deleteExperience(userId, experienceId);

  Future<List<Experience>> getExperiencesByUserId(String userId) =>
      experienceRepository.getExperiencesByUserId(userId);

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
}
