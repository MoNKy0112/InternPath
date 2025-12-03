import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin · Operaciones',
      currentPageIndex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Panel de administrador',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _TileCard(
                  icon: Icons.business,
                  label: 'CRUD Empresas',
                  color: Colors.teal,
                  onTap: () => context.push('/admin/companies'),
                ),
                _TileCard(
                  icon: Icons.person_add,
                  label: 'Registrar modder',
                  color: Colors.deepPurple,
                  onTap: () => context.push('/admin/register_modder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _TileCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
