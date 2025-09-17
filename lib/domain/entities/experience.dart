class Experience {
  final String id;
  final String companyId;
  final String positionTitle;
  final double salary;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final bool flexSchedule;
  final bool continueOption;

  String? description;

  Experience({
    required this.id,
    required this.companyId,
    required this.positionTitle,
    required this.salary,
    required this.startDate,
    required this.endDate,
    required this.userId,
    required this.flexSchedule,
    required this.continueOption,
    this.description,
  });
}
