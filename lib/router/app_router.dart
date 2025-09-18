import 'package:go_router/go_router.dart';
import 'package:internpath/presentation/screens/experiences/create_experience.dart';
import 'package:internpath/presentation/screens/home/home_screen.dart';

import 'package:internpath/presentation/screens/login/login_screen.dart';
import 'package:internpath/presentation/screens/register/register_screen.dart';

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
    ],
  );
}
