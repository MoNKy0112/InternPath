import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/data/firebase/firebase_experience_service.dart';
import 'package:internpath/data/repositories/experience_repository_impl.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';
import 'package:internpath/presentation/widgets/experience_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  late final ExperienceUseCases _experienceUseCases;

  final List<Experience> experiences = [];
  bool isLoading = false;
  Experience? lastExperience;

  // final List<ExperienceCard> experiences = [
  //   // Example experiences
  //   ExperienceCard(
  //     experience: Experience(
  //       id: '1',
  //       companyId: 'Tech Corp',
  //       positionTitle: 'Software Intern',
  //       startDate: DateTime(2023, 6, 1),
  //       endDate: DateTime(2023, 8, 31),
  //       description: 'Worked on developing mobile applications.',
  //       userId: 'user123',
  //       flexSchedule: true,
  //       continueOption: false,
  //       salary: 1,
  //     ),
  //   ),
  //   ExperienceCard(
  //     experience: Experience(
  //       id: '2',
  //       companyId: 'Innovate LLC',
  //       positionTitle: 'Data Science Intern',
  //       startDate: DateTime(2023, 5, 1),
  //       endDate: DateTime(2023, 7, 31),
  //       description: 'Assisted in data analysis and visualization projects.',
  //       userId: 'user123',
  //       flexSchedule: false,
  //       continueOption: true,
  //       salary: 100000,
  //     ),
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final experienceRepository = ExperienceRepositoryImpl(
      FirebaseExperienceService(firestore),
    );
    _experienceUseCases = ExperienceUseCases(experienceRepository);
    _loadExperiences("test11111");
  }

  Future<void> _loadExperiences(String userId, {bool loadMore = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final newExperiences = await _experienceUseCases.getAllExperiences(
        excludeUserId: userId,
        limit: 10,
        lastExperience: loadMore ? lastExperience : null,
      );

      if (!mounted) return; // 👈 aquí verificamos antes de modificar el estado

      setState(() {
        if (loadMore) {
          experiences.addAll(newExperiences);
        } else {
          experiences
            ..clear()
            ..addAll(newExperiences);
        }
        if (newExperiences.isNotEmpty) {
          lastExperience = newExperiences.last;
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // 👈 aquí también
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading experiences: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Home Screen',
      currentPageIndex: currentPageIndex,
      scaffoldExtras: {
        'floatingActionButton': FloatingActionButton(
          onPressed: () {
            context.go('/experiences/create');
          },
          child: const Icon(Icons.add),
        ),
        'floatingActionButtonLocation': FloatingActionButtonLocation.endFloat,
      },
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            // 👇 redirigimos *después* del build, sin romperlo
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.go('/login');
            });
            return const SizedBox.shrink();
          }

          // Aquí cambiamos esto:
          if (experiences.isEmpty && !isLoading) {
            // _loadExperiences("test11111"); ❌
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _loadExperiences("test11111"); // ahora usamos el uid real
            });
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!isLoading &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _loadExperiences("test11111", loadMore: true);
              }
              return false;
            },
            child: ListView.builder(
              itemCount: experiences.length + 1,
              itemBuilder: (context, index) {
                if (index < experiences.length) {
                  return ExperienceCard(experience: experiences[index]);
                } else {
                  return isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
