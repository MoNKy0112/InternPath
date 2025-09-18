import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/entities/experience.dart';

class ExperienceCard extends StatelessWidget {
  final Experience experience;

  const ExperienceCard({super.key, required this.experience});

  void deleteExperience(String experienceId) {
    // TODO: crear vista de confirmación
  }

  void editExperience(String experienceId, BuildContext context) {
    // redireccionar a la pantalla de edición
    context.go('/experiences/edit/$experienceId');
  }

  @override
  Widget build(BuildContext context) {
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
                    experience.companyId,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${experience.startDate.toString()} - ${experience.endDate.toString()}',
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
                    onPressed: () => editExperience(experience.id, context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteExperience(experience.id),
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
