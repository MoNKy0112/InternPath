import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/data/firebase/firebase_auth_service.dart';
import 'package:internpath/data/firebase/firebase_experience_service.dart';
import 'package:internpath/data/repositories/experience_repository_impl.dart';
import 'package:internpath/data/repositories/user_repository_impl.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DependencyInjection {
  static List<SingleChildWidget> buildProviders() {
    ///// Configurar Firestore
    final firestore = FirebaseFirestore.instance;
    ///// Configurar Repositorios y Casos de Uso
    //// Experience
    final experienceRepository = ExperienceRepositoryImpl(
      FirebaseExperienceService(firestore),
    );
    final experienceUseCases = ExperienceUseCases(experienceRepository);
    ////User
    final userRepository = UserRepositoryImpl(FirebaseAuthService(), firestore);
    final authUseCase = AuthUseCases(userRepository);

    return [
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      Provider<ExperienceUseCases>.value(value: experienceUseCases),
      Provider<AuthUseCases>.value(value: authUseCase),
    ];
  }
}
