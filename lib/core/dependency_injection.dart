import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/data/firebase/firebase_experience_service.dart';
import 'package:internpath/data/repositories/experience_repository_impl.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:provider/provider.dart';

class DependencyInjection {
  static List<Provider> buildProviders() {
    final firestore = FirebaseFirestore.instance;
    final experienceRepository = ExperienceRepositoryImpl(
      FirebaseExperienceService(firestore),
    );
    final experienceUseCases = ExperienceUseCases(experienceRepository);

    return [Provider<ExperienceUseCases>.value(value: experienceUseCases)];
  }
}
