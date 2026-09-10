import 'package:intl/intl.dart';
import 'app_locale.dart';
import '../l10n/app_localizations.dart';

/// Date and time wording shared across screens.
///
/// These lived as copies in two vitals screens. Pulled out here so a
/// change to the wording happens in one place.


/// "Today", "Yesterday", or a short date. Relative wording is easier to
/// scan than a bare date when the question is "how recent is this".
/// "Today", "Yesterday", or a short date.
///
/// [t] is optional so callers that haven't been localised yet keep
/// working in English rather than breaking - screens migrate one at a
/// time.
String relativeDay(DateTime when, [AppText? t]) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(when.year, when.month, when.day);
  final difference = today.difference(day).inDays;

  if (difference == 0) return t?.dateToday ?? 'Today';
  if (difference == 1) return t?.dateYesterday ?? 'Yesterday';
  if (difference > 1 && difference < 7) {
    return t?.dateDaysAgo(difference) ?? '$difference days ago';
  }
  return shortDate(when);
}

/// Month names come from intl with the app locale, so they follow the
/// language without a hardcoded list per translation.
String shortDate(DateTime when) =>
    DateFormat('d MMM y', AppLocale().value.languageCode).format(when);

/// Axis-label form: no year, since a chart already sits in a
/// known time range.
String dayMonth(DateTime when) =>
    DateFormat('d MMM', AppLocale().value.languageCode).format(when);

/// Deliberately hand-built rather than DateFormat.jm(): that produces
/// "9:05 AM" where this app has always shown "9:05am", and hour and
/// minute need no locale data anyway.
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
