import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internpath/domain/entities/request.dart';

class RequestModel extends Request {
  RequestModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.status,
    required super.data,
    super.modderId,
  });

  factory RequestModel.fromMap(Map<String, dynamic> json, String id) {
    return RequestModel(
      id: id,
      userId: json['userId'],
      modderId: json['modderId'],
      type: RequestType.values.firstWhere(
        (e) => e.toString() == 'RequestType.${json['type']}',
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.toString() == 'RequestStatus.${json['status']}',
      ),
      data: json['data'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'modderId': modderId,
      'type': type.name,
      'status': status.name,
      'data': data,
    };
  }

  factory RequestModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      modderId: data['modderId'],
      type: RequestType.values.firstWhere(
        (e) => e.toString() == 'RequestType.${data['type']}',
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.toString() == 'RequestStatus.${data['status']}',
      ),
      data: data['data'] ?? {},
    );
  }

  factory RequestModel.fromEntity(Request request) {
    return RequestModel(
      id: request.id,
      userId: request.userId,
      modderId: request.modderId,
      type: request.type,
      status: request.status,
      data: request.data,
    );
  }

  Request toEntity() {
    return Request(
      id: id,
      userId: userId,
      modderId: modderId,
      type: type,
      status: status,
      data: data,
    );
  }
}
