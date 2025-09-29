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
    final user = authProvider.currentUser;
    final authUseCases = context.read<AuthUseCases>();
    if (user == null) {
      // Si no hay usuario, redirigir a la pantalla de login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('No user logged in, redirecting to login');
        print(user);
        context.go('/login');
      });
      return const SizedBox.shrink();
    }

    void _editProfile() {
      context.go('/profile/edit');
    }

    void _viewExperiences() {
      context.go('/experiences/personal');
    }

    void _viewSettings() {
      context.go('/settings');
    }

    void _logout() async {
      await authUseCases.signOut();
      if (context.mounted) {
        context.go('/login');
      }
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

              // Ejemplo de contenido
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName != "" ? user.displayName! : "Usuario",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.email != null)
                        Text(user.email!, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  TextButton(
                    onPressed: _editProfile,
                    child: const Text("Editar"),
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text("Mis Experiencias"),
                onTap: _viewExperiences,
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Configuración"),
                onTap: _viewSettings,
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Cerrar sesión"),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
