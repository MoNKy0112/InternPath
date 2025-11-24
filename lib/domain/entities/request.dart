class Request {
  final String id;
  final String userId;
  final String? modderId;
  final RequestType type;
  final RequestStatus status;
  final Map<String, dynamic> data;

  Request({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.data,
    this.modderId,
  });
}

enum RequestStatus { pending, approved, rejected }

enum RequestType { companySuggestion, editRequest, reportIssue, other }
