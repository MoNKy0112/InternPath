import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final String companyName;

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.companyName,
  });

  Future<void> deleteExperience(
    BuildContext context,
    String experienceId,
  ) async {
    Navigator.of(context).pop(); // Cerrar el diálogo
    final experienceUseCase = context.read<ExperienceUseCases>();
    await experienceUseCase.deleteExperience(
      FirebaseAuth.instance.currentUser!.uid,
      experienceId,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experiencia eliminada correctamente')),
      );
    }
  }

  void showDeleteExperienceDialog(BuildContext context, String experienceId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar esta experiencia?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => deleteExperience(context, experienceId),
            ),
          ],
        );
      },
    );
  }

  void editExperience(BuildContext context, String experienceId) {
    // redireccionar a la pantalla de edición
    context.go('/experiences/edit/$experienceId');
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.work, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.positionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    companyName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${dateFormat.format(experience.startDate)} - ${dateFormat.format(experience.endDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    experience.description ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // si el usuario actual es el dueño de la experiencia, mostrar botones de editar y eliminar
                if (FirebaseAuth.instance.currentUser?.uid ==
                    experience.userId) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => editExperience(context, experience.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        showDeleteExperienceDialog(context, experience.id),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
