import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/data/models/experience_model.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';
import 'package:internpath/presentation/widgets/experience_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
  final List<ExperienceCard> experiences = [
    // Example experiences
    ExperienceCard(
      experience: ExperienceModel(
        id: '1',
        company: 'Tech Corp',
        jobTitle: 'Software Intern',
        startDate: DateTime(2023, 6, 1),
        endDate: DateTime(2023, 8, 31),
        description: 'Worked on developing mobile applications.',
        userId: 'user123',
        flexSchedule: true,
        continueOption: false,
        salary: 1,
      ),
    ),
    ExperienceCard(
      experience: ExperienceModel(
        id: '2',
        company: 'Innovate LLC',
        jobTitle: 'Data Science Intern',
        startDate: DateTime(2023, 5, 1),
        endDate: DateTime(2023, 7, 31),
        description: 'Assisted in data analysis and visualization projects.',
        userId: 'user123',
        flexSchedule: false,
        continueOption: true,
        salary: 100000,
      ),
    ),
  ];

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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to InternPath!'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: experiences.length,
                itemBuilder: (context, index) {
                  return experiences[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
