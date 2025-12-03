import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/entities/request.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  final VoidCallback? onTap;

  const RequestCard({super.key, required this.request, this.onTap});

  Color get _bgColor {
    switch (request.status) {
      case RequestStatus.approved:
        return Colors.green.shade50;
      case RequestStatus.rejected:
        return Colors.red.shade50;
      case RequestStatus.pending:
        return Colors.grey.shade50;
    }
  }

  Color get _accentColor {
    switch (request.status) {
      case RequestStatus.approved:
        return Colors.green.shade700;
      case RequestStatus.rejected:
        return Colors.red.shade700;
      case RequestStatus.pending:
        return Colors.grey.shade600;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case RequestStatus.approved:
        return 'Aprobado';
      case RequestStatus.rejected:
        return 'Rechazado';
      case RequestStatus.pending:
        return 'Pendiente';
    }
  }

  String get _typeLabel {
    switch (request.type) {
      case RequestType.companySuggestion:
        return 'Sugerencia de empresa';
      case RequestType.editRequest:
        return 'Solicitud de edición';
      case RequestType.reportIssue:
        return 'Reporte';
      case RequestType.other:
        return 'Otro';
    }
  }

  String get _displayUserName {
    return request.userName;
  }

  String get _formattedDate {
    final data = request.data;
    final dynamic raw = data['date'] ?? data['createdAt'] ?? data['timestamp'];
    DateTime? d;
    if (raw is DateTime) {
      d = raw;
    } else if (raw is int) {
      d = DateTime.fromMillisecondsSinceEpoch(raw);
      if (d.year == 1970 && raw.toString().length <= 10) {
        d = DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      }
    } else if (raw is String) {
      d = DateTime.tryParse(raw);
      if (d == null) {
        final parsedInt = int.tryParse(raw);
        if (parsedInt != null) {
          d = DateTime.fromMillisecondsSinceEpoch(parsedInt);
        }
      }
    }
    if (d == null) return 'Unknown';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final handleTap =
        onTap ??
        () {
          // usar GoRouter para navegar a la ruta con :id
          GoRouter.of(context).push('/request_detail/${request.id}');
        };

    return InkWell(
      onTap: handleTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentColor.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 56,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _typeLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _displayUserName,
                          style: TextStyle(color: Colors.grey.shade800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accentColor.withOpacity(0.18)),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  color: _accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
