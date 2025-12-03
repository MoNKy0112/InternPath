class Request {
  final String id;
  final String userId;
  final String userName;
  final String? modderId;
  final RequestType type;
  final RequestStatus status;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  Request({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.status,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    this.modderId,
  });
}

enum RequestStatus { pending, approved, rejected }

enum RequestType { companySuggestion, editRequest, reportIssue, other }
