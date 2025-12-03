import 'package:intl/intl.dart';

class DateFormatter extends DateFormat {
  DateFormatter() : super('dd-MM-yyyy');

  String formatDateRange({DateTime? start, DateTime? end}) {
    final startStr = start != null ? format(start) : 'Unknown';
    final endStr = end != null ? format(end) : 'Present';
    return '$startStr - $endStr';
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return format(date);
  }
}
