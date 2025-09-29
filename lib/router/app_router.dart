import 'package:go_router/go_router.dart';
import 'package:internpath/presentation/screens/experiences/create_experience.dart';
import 'package:internpath/presentation/screens/experiences/experience_list.dart';
import 'package:internpath/presentation/screens/home/home_screen.dart';

import 'package:internpath/presentation/screens/user/login/login_screen.dart';
import 'package:internpath/presentation/screens/user/profile/edit_profile_screen.dart';
import 'package:internpath/presentation/screens/user/register/register_screen.dart';
import 'package:internpath/presentation/screens/user/reset_password/reset_password_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/experiences/create',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/experiences/create',
        name: 'create_experience',
        builder: (context, state) => const CreateExperience(),
      ),
      GoRoute(
        path: '/experiences/edit/:id',
        name: 'edit_experience',
        builder: (context, state) {
          final experienceId = state.pathParameters['id'];
          return CreateExperience(experienceId: experienceId);
        },
      ),
      GoRoute(
        path: '/experiences',
        name: 'experience_list',
        builder: (context, state) =>
            const ExperienceList(isPersonalExperienceList: false),
      ),
      GoRoute(
        path: '/experiences/personal',
        name: 'personal_experience_list',
        builder: (context, state) =>
            const ExperienceList(isPersonalExperienceList: true),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit_profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      GoRoute(
        path: '/reset-password',
        name: 'reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
    ],
  );
}
