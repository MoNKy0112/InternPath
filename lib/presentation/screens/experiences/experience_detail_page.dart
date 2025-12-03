import 'package:flutter/material.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/entities/user.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/utils/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // <--- agregado

class ExperienceDetailPage extends StatefulWidget {
  final String experienceId;

  const ExperienceDetailPage({super.key, required this.experienceId});

  @override
  State<ExperienceDetailPage> createState() => _ExperienceDetailPageState();
}

class _ExperienceDetailPageState extends State<ExperienceDetailPage> {
  bool isLoading = true;
  Experience? experience;
  User? ownerUser;
  Company? company;
  DateFormatter dateFormatter = DateFormatter();

  @override
  void initState() {
    super.initState();
    _loadFullData();
  }

  Future<void> _loadFullData() async {
    final expUseCases = context.read<ExperienceUseCases>();
    final userUseCases = context.read<AuthUseCases>();
    final companyUseCases = context.read<CompanyUseCases>();

    // 1. Traer la experiencia
    final exp = await expUseCases.getExperienceById(widget.experienceId);

    if (exp == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experiencia no encontrada')),
      );
      Navigator.of(context).pop();
      return;
    }

    // 2. Traer user y company en paralelo
    final results = await Future.wait([
      userUseCases.getUserById(exp.userId),
      companyUseCases.getCompanyById(exp.companyId),
    ]);

    if (!mounted) return;

    setState(() {
      experience = exp;
      ownerUser = results[0] as User;
      company = results[1] as Company?;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final exp = experience!;
    final owner = ownerUser!;
    final comp = company!;

    String initials(String name) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isEmpty) return '';
      if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              // fallback: ir a la lista de experiencias (o a la ruta que prefieras)
              router.go('/experiences');
            }
          },
        ),
        title: Text(exp.positionTitle),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card with company avatar and basic info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        initials(comp.name),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.positionTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            comp.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            owner.fullName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Dates and status
            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inicio',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateFormatter.formatDate(exp.startDate),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fin',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateFormatter.formatDate(exp.endDate),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.description_outlined,
                          size: 18,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Descripción',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      exp.description?.isNotEmpty == true
                          ? exp.description!
                          : 'Sin descripción.',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Quick facts (salary, flex, continue option) — mismo alto
            const SizedBox(height: 4),
            // adaptative row: cada card toma la altura del más alto sin overflow
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Icon(Icons.attach_money, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text(
                              '\$${exp.salary}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Salario',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      color: Colors.green.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              exp.flexSchedule
                                  ? Icons.check_circle
                                  : Icons.remove_circle,
                              color: exp.flexSchedule
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exp.flexSchedule ? 'Sí' : 'No',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Horario flexible',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      color: Colors.orange.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              exp.continueOption ? Icons.repeat : Icons.block,
                              color: exp.continueOption
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              exp.continueOption ? 'Sí' : 'No',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                'Opción de continuar',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Se eliminó la sección de "Contactar"
          ],
        ),
      ),
    );
  }
}
