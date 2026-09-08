import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/models/consultation_record.dart';
import 'package:medivoice_ai/models/health_profile.dart';
import 'package:medivoice_ai/models/vital_reading.dart';
import 'package:medivoice_ai/services/consultation_history_service.dart';
import 'package:medivoice_ai/services/health_data_service.dart';
import 'package:medivoice_ai/services/health_profile_service.dart';
import 'package:medivoice_ai/services/vitals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _seedAll() async {
  await HealthProfileService().save(const HealthProfile(name: 'Ethin'));
  await VitalsService().add(VitalReading(
    id: 'v1',
    type: VitalType.weight,
    timestamp: DateTime(2026, 9, 7),
    value: 70,
  ));
  await ConsultationHistoryService().add(ConsultationRecord(
    id: 'c1',
    timestamp: DateTime(2026, 9, 7),
    symptoms: const ['cough'],
    disease: 'Common Cold',
    confidence: 0.8,
  ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('hasAnyData', () {
    test('false on a fresh install', () async {
      expect(await HealthDataService().hasAnyData(), isFalse);
    });

    test('true when only a profile exists', () async {
      await HealthProfileService().save(const HealthProfile(name: 'Ethin'));
      expect(await HealthDataService().hasAnyData(), isTrue);
    });

    test('true when only a vital reading exists', () async {
      await VitalsService().add(VitalReading(
        id: 'v1',
        type: VitalType.pulse,
        timestamp: DateTime(2026, 9, 7),
        value: 72,
      ));
      expect(await HealthDataService().hasAnyData(), isTrue);
    });

    test('true when only an assessment exists', () async {
      await ConsultationHistoryService().add(ConsultationRecord(
        id: 'c1',
        timestamp: DateTime(2026, 9, 7),
        symptoms: const ['cough'],
      ));
      expect(await HealthDataService().hasAnyData(), isTrue);
    });
  });

  group('clearAll', () {
    test('removes every store, not just some of them', () async {
      await _seedAll();
      await HealthDataService().clearAll();

      expect(await HealthProfileService().load(), isNull);
      expect(await VitalsService().loadAll(), isEmpty);
      expect(await ConsultationHistoryService().load(), isEmpty);
    });

    test('is safe to call when nothing is stored', () async {
      await HealthDataService().clearAll();
      expect(await HealthDataService().hasAnyData(), isFalse);
    });

    test('leaves settings alone - they are not health data', () async {
      SharedPreferences.setMockInitialValues({
        'text_size': 'large',
        'unit_temperature': 'celsius',
        'preferred_language': 'kn',
      });
      await _seedAll();
      await HealthDataService().clearAll();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('text_size'), 'large');
      expect(prefs.getString('unit_temperature'), 'celsius');
      expect(prefs.getString('preferred_language'), 'kn');
    });
  });

  group('summary', () {
    test('empty when nothing is stored', () async {
      expect(await HealthDataService().summary(), isEmpty);
    });

    test('names each kind of stored data', () async {
      await _seedAll();
      final summary = await HealthDataService().summary();
      expect(summary.length, 3);
      expect(summary.any((s) => s.contains('profile')), isTrue);
      expect(summary.any((s) => s.contains('vital reading')), isTrue);
      expect(summary.any((s) => s.contains('past assessment')), isTrue);
    });

    test('singular and plural read correctly', () async {
      await VitalsService().add(VitalReading(
        id: 'v1',
        type: VitalType.pulse,
        timestamp: DateTime(2026, 9, 7),
        value: 72,
      ));
      expect((await HealthDataService().summary()).single,
          '1 vital reading');

      await VitalsService().add(VitalReading(
        id: 'v2',
        type: VitalType.pulse,
        timestamp: DateTime(2026, 9, 6),
        value: 74,
      ));
      expect((await HealthDataService().summary()).single,
          '2 vital readings');
    });
  });
}
