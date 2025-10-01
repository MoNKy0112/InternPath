import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';
import 'package:internpath/presentation/widgets/experience_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  late ExperienceUseCases _experienceUseCases;

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

    // final user = context.watch<AuthProvider>().currentUser;

    _experienceUseCases = context.read<ExperienceUseCases>();
    // _loadExperiences(user?.uid ?? '');
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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      // Redirigimos si no hay sesión
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        print('No user logged in, redirecting to login');
        print(user);
        context.go('/login');
      });
      return const SizedBox.shrink();
    }

    // Cargar experiencias si aún no hay
    if (experiences.isEmpty && !isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadExperiences(user.uid);
      });
    }

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
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!isLoading &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadExperiences(
              user.uid,
              loadMore: true,
            ); // 👈 carga más al llegar abajo
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            // 👈 aquí vuelves a cargar desde el inicio
            await _loadExperiences(user.uid, loadMore: false);
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
        ),
      ),
    );
  }
}
