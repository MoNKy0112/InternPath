class ExperienceModel {
  final String id;
  final String company;
  final String jobTitle;
  final num salary;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final bool flexSchedule;
  final bool continueOption;

  String? description;

  ExperienceModel({
    required this.id,
    required this.company,
    required this.jobTitle,
    required this.salary,
    required this.startDate,
    required this.endDate,
    required this.userId,
    required this.flexSchedule,
    required this.continueOption,
    this.description,
  });

  String get position => jobTitle;
}
