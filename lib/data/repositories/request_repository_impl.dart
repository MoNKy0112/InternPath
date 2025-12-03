import 'package:internpath/data/firebase/firebase_request_service.dart';
import 'package:internpath/data/models/request_model.dart';
import 'package:internpath/domain/entities/request.dart';
import 'package:internpath/domain/repositories/request_repository.dart';

class RequestRepositoryImpl implements RequestRepository {
  final FirebaseRequestService _firebaseService;

  RequestRepositoryImpl(this._firebaseService);

  @override
  Future<void> createRequest(Request request) async {
    final model = RequestModel(
      id: request.id,
      userId: request.userId,
      userName: request.userName,
      type: request.type,
      status: request.status,
      data: request.data,
      modderId: request.modderId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firebaseService.create(model.toMap());
  }

  @override
  Future<Request> getRequestById(String requestId) async {
    final doc = await _firebaseService.getById(requestId);
    return RequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<List<Request>> getRequestsByUser(String userId) async {
    final snapshot = await _firebaseService.getByUser(userId);
    return snapshot.docs
        .map(
          (doc) =>
              RequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  @override
  Future<List<Request>> getPendingRequests() async {
    final snapshot = await _firebaseService.getPending();
    return snapshot.docs
        .map(
          (doc) =>
              RequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  @override
  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status, {
    String? modderId,
  }) async {
    await _firebaseService.updateStatus(requestId, {
      'status': status.name,
      'modderId': modderId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
