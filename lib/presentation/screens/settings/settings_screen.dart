import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmAndSend(BuildContext context, String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer contraseña'),
        content: Text(
          '¿Deseas enviar un correo de restablecimiento a "$email"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // mostrar indicador mientras se envía
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authUseCases = context.read<AuthUseCases>();
      await authUseCases.sendPasswordResetEmail(email);
      if (context.mounted) {
        Navigator.of(context).pop(); // cerrar indicador
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Correo de restablecimiento enviado. Revisa tu bandeja.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // cerrar indicador
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al enviar correo: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final firebaseUser = authProvider.currentUser;
    final email = firebaseUser?.email;

    void editProfile() {
      context.push('/profile/edit');
    }

    return AppScaffold(
      title: 'Configuración',
      currentPageIndex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Restablecer contraseña'),
                subtitle: Text(email ?? 'No hay email asociado'),
                enabled: email != null && email.isNotEmpty,
                onTap: email == null || email.isEmpty
                    ? null
                    : () => _confirmAndSend(context, email),
              ),
            ),
            const SizedBox(height: 12),
            // puedes añadir más opciones aquí
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Editar perfil'),
                onTap: editProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
