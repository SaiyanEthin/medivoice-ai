import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medivoice_ai/core/date_format.dart';

void main() {
  // shortDate uses intl for month names, which needs its data loaded.
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  group('greetingForHour', () {
    test('morning before noon', () {
      expect(greetingForHour(0), 'Good morning');
      expect(greetingForHour(9), 'Good morning');
      expect(greetingForHour(11), 'Good morning');
    });

    test('afternoon from noon', () {
      expect(greetingForHour(12), 'Good afternoon');
      expect(greetingForHour(16), 'Good afternoon');
    });

    test('evening from five', () {
      expect(greetingForHour(17), 'Good evening');
      expect(greetingForHour(23), 'Good evening');
    });
  });

  group('relativeDay', () {
    test('today', () {
      expect(relativeDay(DateTime.now()), 'Today');
    });

    test('yesterday', () {
      expect(
          relativeDay(DateTime.now().subtract(const Duration(days: 1))),
          'Yesterday');
    });

    test('within the last week counts days', () {
      expect(
          relativeDay(DateTime.now().subtract(const Duration(days: 3))),
          '3 days ago');
    });

    test('older than a week falls back to a date', () {
      final old = DateTime(2026, 1, 15);
      expect(relativeDay(old), '15 Jan 2026');
    });

    test('a future date does not read as a day count', () {
      final future = DateTime.now().add(const Duration(days: 3));
      expect(relativeDay(future), isNot(contains('days ago')));
    });
  });

  group('clockTime', () {
    test('morning', () {
      expect(clockTime(DateTime(2026, 9, 7, 9, 5)), '9:05am');
    });

    test('afternoon', () {
      expect(clockTime(DateTime(2026, 9, 7, 14, 30)), '2:30pm');
    });

    test('midnight reads as 12am', () {
      expect(clockTime(DateTime(2026, 9, 7, 0, 0)), '12:00am');
    });

    test('noon reads as 12pm', () {
      expect(clockTime(DateTime(2026, 9, 7, 12, 0)), '12:00pm');
    });
  });

  test('shortDate formats day, month, year', () {
    expect(shortDate(DateTime(2026, 12, 3)), '3 Dec 2026');
  });
}
