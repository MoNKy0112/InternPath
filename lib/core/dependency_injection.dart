import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/data/firebase/firebase_auth_service.dart';
import 'package:internpath/data/firebase/firebase_company_service.dart';
import 'package:internpath/data/firebase/firebase_experience_service.dart';
import 'package:internpath/data/firebase/firebase_request_service.dart';
import 'package:internpath/data/firebase/firebase_user_service.dart';
import 'package:internpath/data/repositories/company_repository_impl.dart';
import 'package:internpath/data/repositories/experience_repository_impl.dart';
import 'package:internpath/data/repositories/request_repository_impl.dart';
import 'package:internpath/data/repositories/user_repository_impl.dart';
import 'package:internpath/domain/repositories/company_repository.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/domain/usecases/request_usecases.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DependencyInjection {
  static List<SingleChildWidget> buildProviders() {
    ///// Configurar Firestore
    final firestore = FirebaseFirestore.instance;
    ///// Configurar Repositorios y Casos de Uso
    ///
    //// Experience
    final experienceRepository = ExperienceRepositoryImpl(
      FirebaseExperienceService(firestore),
    );
    final experienceUseCases = ExperienceUseCases(experienceRepository);

    ////User
    final userRepository = UserRepositoryImpl(
      FirebaseAuthService(),
      FirebaseUserService(firestore),
    );
    final authUseCase = AuthUseCases(userRepository);

    //// Company
    final companyRepository = CompanyRepositoryImpl(
      FirebaseCompanyService(firestore),
    );
    final companyUseCases = CompanyUseCases(companyRepository);

    //// Request
    final requestRepository = RequestRepositoryImpl(FirebaseRequestService());
    final requestUseCases = RequestUseCases(requestRepository);

    return [
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      Provider<ExperienceUseCases>.value(value: experienceUseCases),
      Provider<AuthUseCases>.value(value: authUseCase),
      Provider<CompanyUseCases>.value(value: companyUseCases),
      Provider<RequestUseCases>.value(value: requestUseCases),
    ];
  }
}
