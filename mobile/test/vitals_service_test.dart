import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/models/vital_reading.dart';
import 'package:medivoice_ai/services/vitals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

VitalReading _reading({
  required String id,
  required VitalType type,
  required DateTime at,
  double value = 120,
  double? secondary,
  String? note,
}) {
  return VitalReading(
    id: id,
    type: type,
    timestamp: at,
    value: value,
    secondaryValue: secondary,
    note: note,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('storage', () {
    test('empty to start', () async {
      expect(await VitalsService().loadAll(), isEmpty);
    });

    test('a blood pressure reading survives a round trip', () async {
      final service = VitalsService();
      final at = DateTime(2026, 9, 7, 9, 15);
      await service.add(_reading(
        id: 'bp1',
        type: VitalType.bloodPressure,
        at: at,
        value: 124,
        secondary: 82,
        note: 'before food',
      ));

      final loaded = (await service.loadAll()).single;
      expect(loaded.type, VitalType.bloodPressure);
      expect(loaded.value, 124);
      expect(loaded.secondaryValue, 82);
      expect(loaded.note, 'before food');
      expect(loaded.timestamp, at);
    });

    test('readings accumulate rather than overwrite', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'w1',
          type: VitalType.weight,
          at: DateTime(2026, 9, 1),
          value: 78.5));
      await service.add(_reading(
          id: 'w2',
          type: VitalType.weight,
          at: DateTime(2026, 9, 7),
          value: 77.9));

      expect((await service.loadByType(VitalType.weight)).length, 2,
          reason: 'a new reading must not replace the previous one');
    });

    test('newest first', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'old', type: VitalType.pulse, at: DateTime(2026, 9, 1)));
      await service.add(_reading(
          id: 'new', type: VitalType.pulse, at: DateTime(2026, 9, 7)));
      await service.add(_reading(
          id: 'mid', type: VitalType.pulse, at: DateTime(2026, 9, 4)));

      final ids = (await service.loadAll()).map((r) => r.id).toList();
      expect(ids, ['new', 'mid', 'old']);
    });
  });

  group('per-type behaviour', () {
    test('backdated readings sort into the right place', () async {
      // Entry allows picking a past date, so a reading added later can be
      // older than one already stored.
      final service = VitalsService();
      await service.add(_reading(
          id: 'today', type: VitalType.weight, at: DateTime(2026, 9, 7)));
      await service.add(_reading(
          id: 'last_week',
          type: VitalType.weight,
          at: DateTime(2026, 8, 31)));
      await service.add(_reading(
          id: 'yesterday',
          type: VitalType.weight,
          at: DateTime(2026, 9, 6)));

      final ids =
          (await service.loadByType(VitalType.weight)).map((r) => r.id);
      expect(ids, ['today', 'yesterday', 'last_week'],
          reason: 'order follows the reading date, not the order added');
    });

    test('latest respects dates rather than insertion order', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'recent',
          type: VitalType.pulse,
          at: DateTime(2026, 9, 7),
          value: 72));
      await service.add(_reading(
          id: 'backdated',
          type: VitalType.pulse,
          at: DateTime(2026, 9, 1),
          value: 80));

      final latest = await service.latest(VitalType.pulse);
      expect(latest!.id, 'recent',
          reason: 'adding an older reading must not change the latest');
    });

    test('loadByType returns only that type', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'a', type: VitalType.pulse, at: DateTime(2026, 9, 1)));
      await service.add(_reading(
          id: 'b', type: VitalType.weight, at: DateTime(2026, 9, 2)));

      expect((await service.loadByType(VitalType.pulse)).map((r) => r.id),
          ['a']);
    });

    test('latest returns the most recent of that type', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'a',
          type: VitalType.temperature,
          at: DateTime(2026, 9, 1),
          value: 98.4));
      await service.add(_reading(
          id: 'b',
          type: VitalType.temperature,
          at: DateTime(2026, 9, 7),
          value: 99.1));

      final latest = await service.latest(VitalType.temperature);
      expect(latest!.id, 'b');
      expect(latest.value, closeTo(99.1, 0.001));
    });

    test('latestOfEach covers every type, null where unrecorded', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'a', type: VitalType.pulse, at: DateTime(2026, 9, 1)));

      final latest = await service.latestOfEach();
      expect(latest.keys.length, VitalType.values.length);
      expect(latest[VitalType.pulse]!.id, 'a');
      expect(latest[VitalType.weight], isNull);
    });

    test('the cap applies per type, not across all types', () async {
      final service = VitalsService();
      for (var i = 0; i < VitalsService.maxPerType + 5; i++) {
        await service.add(_reading(
          id: 'w$i',
          type: VitalType.weight,
          at: DateTime(2026, 1, 1).add(Duration(days: i)),
        ));
      }
      await service.add(_reading(
          id: 'p1', type: VitalType.pulse, at: DateTime(2026, 1, 1)));

      expect((await service.loadByType(VitalType.weight)).length,
          VitalsService.maxPerType);
      expect((await service.loadByType(VitalType.pulse)).length, 1,
          reason: 'one type overflowing must not evict another');
    });
  });

  group('deletion', () {
    test('delete removes a single reading', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'a', type: VitalType.pulse, at: DateTime(2026, 9, 1)));
      await service.add(_reading(
          id: 'b', type: VitalType.pulse, at: DateTime(2026, 9, 2)));

      await service.delete('a');
      expect((await service.loadAll()).map((r) => r.id), ['b']);
    });

    test('clearType leaves other types alone', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'a', type: VitalType.pulse, at: DateTime(2026, 9, 1)));
      await service.add(_reading(
          id: 'b', type: VitalType.weight, at: DateTime(2026, 9, 2)));

      await service.clearType(VitalType.pulse);
      expect((await service.loadAll()).map((r) => r.id), ['b']);
    });

    test('clearAll empties everything', () async {
      final service = VitalsService();
      await service.add(_reading(
          id: 'a', type: VitalType.pulse, at: DateTime(2026, 9, 1)));
      await service.clearAll();
      expect(await service.loadAll(), isEmpty);
    });
  });

  group('formatting and metadata', () {
    test('blood pressure formats as systolic/diastolic', () {
      final reading = _reading(
        id: 'a',
        type: VitalType.bloodPressure,
        at: DateTime(2026, 9, 1),
        value: 124,
        secondary: 82,
      );
      expect(reading.formatted, '124/82');
    });

    test('temperature keeps one decimal', () {
      final reading = _reading(
        id: 'a',
        type: VitalType.temperature,
        at: DateTime(2026, 9, 1),
        value: 98.4,
      );
      expect(reading.formatted, '98.4');
    });

    test('pulse shows as a whole number', () {
      final reading = _reading(
        id: 'a',
        type: VitalType.pulse,
        at: DateTime(2026, 9, 1),
        value: 72,
      );
      expect(reading.formatted, '72');
    });

    test('only blood pressure has a second value', () {
      for (final type in VitalType.values) {
        expect(type.hasSecondary, type == VitalType.bloodPressure);
      }
    });

    test('every type has a label and a unit', () {
      for (final type in VitalType.values) {
        expect(type.label, isNotEmpty);
        expect(type.unit, isNotEmpty);
      }
    });
  });

  test('corrupt stored data reads as empty, not thrown', () async {
    SharedPreferences.setMockInitialValues({'vital_readings': 'nonsense'});
    expect(await VitalsService().loadAll(), isEmpty);
  });

  test('an unknown vital type is skipped rather than crashing', () async {
    SharedPreferences.setMockInitialValues({
      'vital_readings':
          '[{"id":"x","type":"someFutureVital","timestamp":"2026-09-07T00:00:00.000","value":1}]'
    });
    expect(await VitalsService().loadAll(), isEmpty);
  });
}
