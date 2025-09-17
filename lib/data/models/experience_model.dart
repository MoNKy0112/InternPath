import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/domain/entities/experience.dart';

class ExperienceModel extends Experience {
  ExperienceModel({
    required super.id,
    required super.companyId,
    required super.positionTitle,
    required super.salary,
    required super.startDate,
    required super.endDate,
    required super.userId,
    required super.flexSchedule,
    required super.continueOption,
    super.description,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> data, String id) {
    return ExperienceModel(
      id: id,
      companyId: data['companyId'],
      positionTitle: data['positionTitle'],
      salary: (data['salary'] as num).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      userId: data['userId'],
      flexSchedule: data['flexSchedule'],
      continueOption: data['continueOption'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "companyId": companyId,
      "positionTitle": positionTitle,
      "salary": salary,
      "startDate": Timestamp.fromDate(startDate),
      "endDate": Timestamp.fromDate(endDate),
      "userId": userId,
      "flexSchedule": flexSchedule,
      "continueOption": continueOption,
      "description": description,
    };
  }

  factory ExperienceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ExperienceModel(
      id: doc.id,
      companyId: data['companyId'] ?? '',
      positionTitle: data['positionTitle'] ?? '',
      salary: (data['salary'] as num).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      flexSchedule: data['flexSchedule'] ?? false,
      continueOption: data['continueOption'] ?? false,
      description: data['description'],
    );
  }

  factory ExperienceModel.fromEntity(Experience entity) {
    return ExperienceModel(
      id: entity.id,
      companyId: entity.companyId,
      positionTitle: entity.positionTitle,
      salary: entity.salary,
      startDate: entity.startDate,
      endDate: entity.endDate,
      userId: entity.userId,
      flexSchedule: entity.flexSchedule,
      continueOption: entity.continueOption,
      description: entity.description,
    );
  }
  Experience toEntity() {
    return Experience(
      id: id,
      companyId: companyId,
      positionTitle: positionTitle,
      salary: salary,
      startDate: startDate,
      endDate: endDate,
      userId: userId,
      flexSchedule: flexSchedule,
      continueOption: continueOption,
      description: description,
    );
  }
}
