import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/models/vital_reading.dart';
import 'package:medivoice_ai/screens/trends_screen.dart';

VitalReading _at(DateTime when) => VitalReading(
      id: when.toIso8601String(),
      type: VitalType.weight,
      timestamp: when,
      value: 70,
    );

void main() {
  final now = DateTime(2026, 9, 7, 12);

  test('null range keeps everything', () {
    final readings = [
      _at(DateTime(2026, 9, 7)),
      _at(DateTime(2025, 1, 1)),
    ];
    expect(readingsWithinDays(readings, null, now: now).length, 2);
  });

  test('a 7 day range keeps only the last week', () {
    final readings = [
      _at(DateTime(2026, 9, 7)),
      _at(DateTime(2026, 9, 3)),
      _at(DateTime(2026, 8, 20)),
    ];
    final kept = readingsWithinDays(readings, 7, now: now);
    expect(kept.length, 2);
    expect(kept.any((r) => r.timestamp.month == 8), isFalse);
  });

  test('a 30 day range reaches further back', () {
    final readings = [
      _at(DateTime(2026, 9, 7)),
      _at(DateTime(2026, 8, 20)),
      _at(DateTime(2026, 6, 1)),
    ];
    expect(readingsWithinDays(readings, 30, now: now).length, 2);
  });

  test('a reading exactly on the boundary is kept', () {
    final readings = [_at(now.subtract(const Duration(days: 7)))];
    expect(readingsWithinDays(readings, 7, now: now).length, 1);
  });

  test('filtering does not mutate the input', () {
    final readings = [
      _at(DateTime(2026, 9, 7)),
      _at(DateTime(2020, 1, 1)),
    ];
    readingsWithinDays(readings, 7, now: now);
    expect(readings.length, 2);
  });

  test('an empty list stays empty', () {
    expect(readingsWithinDays([], 7, now: now), isEmpty);
  });
}
