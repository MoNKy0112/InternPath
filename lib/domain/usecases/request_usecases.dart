import 'package:internpath/domain/entities/request.dart';
import 'package:internpath/domain/repositories/request_repository.dart';

class RequestUseCases {
  final RequestRepository requestRepository;

  RequestUseCases(this.requestRepository);

  Future<void> createRequest(Request request) =>
      requestRepository.createRequest(request);

  Future<List<Request>> getRequestsByUser(String userId) =>
      requestRepository.getRequestsByUser(userId);

  Future<List<Request>> getPendingRequests() =>
      requestRepository.getPendingRequests();

  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status, {
    String? modderId,
  }) => requestRepository.updateRequestStatus(
    requestId,
    status,
    modderId: modderId,
  );
}
