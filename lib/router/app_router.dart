import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/presentation/screens/company/company_detail_screen.dart';
import 'package:internpath/presentation/screens/search/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:internpath/presentation/screens/admin/admin_home_screen.dart';
import 'package:internpath/presentation/screens/admin/company_admin_screen.dart';
import 'package:internpath/presentation/screens/admin/company_edit_screen.dart';
import 'package:internpath/presentation/screens/admin/modder_registration_screen.dart';
import 'package:internpath/presentation/screens/experiences/create_experience.dart';
import 'package:internpath/presentation/screens/experiences/experience_detail_page.dart';
import 'package:internpath/presentation/screens/experiences/experience_list.dart';
import 'package:internpath/presentation/screens/requests/request_detail_screen.dart';
import 'package:internpath/presentation/screens/requests/request_list.dart';
import 'package:internpath/presentation/screens/user/login/login_screen.dart';
import 'package:internpath/presentation/screens/user/profile/edit_profile_screen.dart';
import 'package:internpath/presentation/screens/user/register/register_screen.dart';
import 'package:internpath/presentation/screens/user/reset_password/reset_password_screen.dart';
import 'package:internpath/presentation/screens/settings/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
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

      // RUTA RAÍZ: redirige dinámicamente según el rol del usuario
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const _RootRedirectScreen(),
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
        path: '/experiences/detail/:id',
        name: 'experience_detail',
        builder: (context, state) {
          final experienceId = state.pathParameters['id']!;
          return ExperienceDetailPage(experienceId: experienceId);
        },
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

      GoRoute(
        path: '/request_detail/:id',
        name: 'request_detail',
        builder: (context, state) {
          final requestId = state.pathParameters['id']!;
          return RequestDetailScreen(requestId: requestId);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/company_detail/:id',
        name: 'company_detail',
        builder: (context, state) {
          final companyId = state.pathParameters['id']!;
          return CompanyDetailScreen(companyId: companyId);
        },
      ),
      GoRoute(
        path: '/requests',
        name: 'request_list',
        builder: (context, state) => const RequestListScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(path: '/admin', builder: (ctx, state) => const AdminHomeScreen()),
      GoRoute(
        path: '/admin/companies',
        builder: (ctx, state) => const CompanyAdminScreen(),
      ),
      GoRoute(
        path: '/admin/companies/create',
        builder: (ctx, state) => const CompanyEditScreen(),
      ),
      GoRoute(
        path: '/admin/companies/edit/:id',
        builder: (ctx, state) =>
            CompanyEditScreen(companyId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/register_modder',
        builder: (ctx, state) => const ModderRegistrationScreen(),
      ),
    ],
  );
}

class _RootRedirectScreen extends StatefulWidget {
  const _RootRedirectScreen({super.key});

  @override
  State<_RootRedirectScreen> createState() => _RootRedirectScreenState();
}

class _RootRedirectScreenState extends State<_RootRedirectScreen> {
  bool _redirected = false;

  void _maybeRedirect(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      final target = '/login';
      GoRouter.of(context).go(target);
      _redirected = true;
      return;
    }

    // si aún está cargando el user de dominio, esperar
    if (auth.isLoadingDomainUser) return;

    final target = auth.isModder ? '/requests' : '/experiences';
    // Navigate to the computed target; the _redirected flag prevents repeating this.
    GoRouter.of(context).go(target);
    _redirected = true;
  }

  @override
  Widget build(BuildContext context) {
    // usar watch para reconstruir cuando cambie el estado del provider
    final auth = context.watch<AuthProvider>();

    // si ya redirigimos, mostramos vacío
    if (_redirected) return const Scaffold(body: SizedBox.shrink());

    // si no hay sesión -> ir a login inmediatamente
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeRedirect(context),
      );
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // si está cargando el domain user mostramos loader y esperamos
    if (auth.isLoadingDomainUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // si llegó aquí y no hemos redirigido aún, redirigimos en next frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeRedirect(context),
    );
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
