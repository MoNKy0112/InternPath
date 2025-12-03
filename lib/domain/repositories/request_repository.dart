import 'package:internpath/domain/entities/request.dart';

abstract class RequestRepository {
  Future<void> createRequest(Request request);
  Future<Request> getRequestById(String requestId);
  Future<List<Request>> getRequestsByUser(String userId);
  Future<List<Request>> getPendingRequests();
  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status, {
    String? modderId,
  });
}
