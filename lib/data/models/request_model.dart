import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/domain/entities/request.dart';

class RequestModel extends Request {
  RequestModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.type,
    required super.status,
    required super.data,
    required super.createdAt,
    required super.updatedAt,
    super.modderId,
  });

  factory RequestModel.fromMap(Map<String, dynamic> json, String id) {
    return RequestModel(
      id: id,
      userId: json['userId'],
      userName: json['userName'],
      modderId: json['modderId'],
      type: RequestType.values.firstWhere(
        (e) => e.toString() == 'RequestType.${json['type']}',
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.toString() == 'RequestStatus.${json['status']}',
      ),
      data: json['data'] ?? {},
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'modderId': modderId,
      'type': type.name,
      'status': status.name,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RequestModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      modderId: data['modderId'],
      type: RequestType.values.firstWhere(
        (e) => e.toString() == 'RequestType.${data['type']}',
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.toString() == 'RequestStatus.${data['status']}',
      ),
      data: data['data'] ?? {},
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory RequestModel.fromEntity(Request request) {
    return RequestModel(
      id: request.id,
      userId: request.userId,
      userName: request.userName,
      modderId: request.modderId,
      type: request.type,
      status: request.status,
      data: request.data,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );
  }

  Request toEntity() {
    return Request(
      id: id,
      userId: userId,
      userName: userName,
      modderId: modderId,
      type: type,
      status: status,
      data: data,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
