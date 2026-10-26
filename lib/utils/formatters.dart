// lib/utils/formatters.dart
//
// Small helpers that keep date text consistent across every screen.

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _monthShortNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdayShortNames = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String formatDate(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
}

String formatShortDate(DateTime date) {
  return '${_monthShortNames[date.month - 1]} ${date.day}';
}

String formatMonthShort(DateTime date) {
  return _monthShortNames[date.month - 1].toUpperCase();
}

String formatDayNumber(DateTime date) {
  return '${date.day}';
}

String formatWeekdayShort(DateTime date) {
  return _weekdayShortNames[date.weekday - 1];
}

String formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String formatDateTime(DateTime date) {
  return '${formatDate(date)} · ${formatTime(date)}';
}

String formatDateRange(DateTime start, DateTime end) {
  final sameDay =
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;

  if (sameDay) {
    return '${formatDate(start)} · ${formatTime(start)} - ${formatTime(end)}';
  }
  return '${formatDateTime(start)} - ${formatDateTime(end)}';
}

String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final difference = today.difference(day).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  if (difference > 1 && difference < 7) return '$difference days ago';
  return formatShortDate(date);
}

String formatDueLabel(DateTime date) {
  return '${formatShortDate(date)} · ${formatTime(date)}';
}

// Used by date/time form fields.
String formatPickerDate(DateTime date) => formatDate(date);
