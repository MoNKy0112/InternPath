import 'package:internpath/domain/entities/experience.dart';

abstract class ExperienceRepository {
  Future<void> addExperience(String userId, Experience experience);
  Future<void> updateExperience(
    String userId,
    String experienceId,
    Experience experience,
  );
  Future<void> deleteExperience(String userId, String experienceId);
  Future<List<Experience>> getExperiencesByUserId(String userId);
  Future<Experience?> getExperienceById(String experienceId);
  Future<List<Experience>> getAllExperiences({
    required String excludeUserId,
    int limit = 10,
    Experience? lastExperience,
  });
}
