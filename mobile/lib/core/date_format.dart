/// Date and time wording shared across screens.
///
/// These lived as copies in two vitals screens. Pulled out here so a
/// change to the wording happens in one place.

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Today", "Yesterday", or a short date. Relative wording is easier to
/// scan than a bare date when the question is "how recent is this".
String relativeDay(DateTime when) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(when.year, when.month, when.day);
  final difference = today.difference(day).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  if (difference > 1 && difference < 7) return '$difference days ago';
  return shortDate(when);
}

String shortDate(DateTime when) =>
    '${when.day} ${_months[when.month - 1]} ${when.year}';

String clockTime(DateTime when) {
  final hour = when.hour % 12 == 0 ? 12 : when.hour % 12;
  final minute = when.minute.toString().padLeft(2, '0');
  final period = when.hour < 12 ? 'am' : 'pm';
  return '$hour:$minute$period';
}

/// Time-of-day greeting. Public so it can be tested without a clock.
String greetingForHour(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
