import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileBottomSheet extends StatelessWidget {
  final Offset offset;
  final Duration duration;

  const ProfileBottomSheet({
    super.key,
    this.offset = Offset.zero,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final firebaseUser = authProvider.currentUser;
    final authUseCases = context.read<AuthUseCases>();

    // si no hay usuario firebase, redirigir al login
    if (firebaseUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const SizedBox.shrink();
    }

    final domainUser = authProvider.domainUser;
    final isLoadingDomainUser = authProvider.isLoadingDomainUser;
    final isAdmin = authProvider.isAdmin;

    print("authProvider.domainUser: ${authProvider.domainUser?.role}");

    void viewExperiences() => context.go('/experiences/personal');
    void viewSettings() => context.go('/settings');
    void viewAdmin() => context.go('/admin');

    void logout() async {
      await authUseCases.signOut();
      if (context.mounted) context.go('/login');
    }

    return AnimatedSlide(
      offset: offset,
      duration: duration,
      curve: Curves.easeOut,
      child: Material(
        elevation: 8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              const Text(
                "Mi Perfil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: firebaseUser.photoURL != null
                        ? NetworkImage(firebaseUser.photoURL!)
                        : null,
                    child: firebaseUser.photoURL == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (firebaseUser.displayName != null &&
                                firebaseUser.displayName!.isNotEmpty)
                            ? firebaseUser.displayName!
                            : "Usuario",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (firebaseUser.email != null)
                        Text(
                          firebaseUser.email!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      const SizedBox(height: 6),
                      // mostrar rol si ya está cargado
                      if (isLoadingDomainUser)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (domainUser != null)
                        Text(
                          domainUser.role
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text("Mis Experiencias"),
                onTap: viewExperiences,
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Configuración"),
                onTap: viewSettings,
              ),

              // opción admin solo si el dominio indica admin
              if (!isLoadingDomainUser && isAdmin)
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.deepPurple,
                  ),
                  title: const Text("Operaciones admin"),
                  subtitle: const Text('Registrar modders · CRUD de empresas'),
                  onTap: viewAdmin,
                ),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Cerrar sesión"),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
