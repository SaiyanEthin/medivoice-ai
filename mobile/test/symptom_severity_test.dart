import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/models/consultation_record.dart';
import 'package:medivoice_ai/models/symptom_severity.dart';
import 'package:medivoice_ai/providers/consultation_provider.dart';
import 'package:medivoice_ai/services/consultation_history_service.dart';
import 'package:medivoice_ai/services/symptom_matcher_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('enum', () {
    test('labels read naturally', () {
      expect(SymptomSeverity.mild.label, 'Mild');
      expect(SymptomSeverity.moderate.label, 'Moderate');
      expect(SymptomSeverity.severe.label, 'Severe');
    });

    test('storage keys round trip', () {
      for (final severity in SymptomSeverity.values) {
        expect(severityFromKey(severity.storageKey), severity);
      }
    });

    test('an unknown or missing key yields null', () {
      expect(severityFromKey('catastrophic'), isNull);
      expect(severityFromKey(null), isNull);
    });
  });

  group('record persistence', () {
    test('severities survive a round trip', () async {
      final service = ConsultationHistoryService();
      await service.add(ConsultationRecord(
        id: 'a',
        timestamp: DateTime(2026, 9, 7),
        symptoms: const ['cough', 'fatigue'],
        disease: 'Common Cold',
        confidence: 0.8,
        severities: const {
          'cough': SymptomSeverity.moderate,
          'fatigue': SymptomSeverity.mild,
        },
      ));

      final loaded = (await service.load()).single;
      expect(loaded.severities['cough'], SymptomSeverity.moderate);
      expect(loaded.severities['fatigue'], SymptomSeverity.mild);
    });

    test('a record with no severities loads as an empty map', () async {
      final service = ConsultationHistoryService();
      await service.add(ConsultationRecord(
        id: 'a',
        timestamp: DateTime(2026, 9, 7),
        symptoms: const ['cough'],
      ));
      expect((await service.load()).single.severities, isEmpty);
    });

    test('records written before severities existed still load', () async {
      // No 'severities' key at all, as older stored records would be.
      SharedPreferences.setMockInitialValues({
        'consultation_history':
            '[{"id":"a","timestamp":"2026-09-07T00:00:00.000",'
            '"symptoms":["cough"],"deniedSymptoms":[],"disease":"Common Cold",'
            '"confidence":0.8,"isUncertain":false,"followupRounds":1}]'
      });
      final loaded = (await ConsultationHistoryService().load()).single;
      expect(loaded.severities, isEmpty);
      expect(loaded.disease, 'Common Cold');
    });

    test('an unrecognised severity value is dropped, not thrown', () async {
      SharedPreferences.setMockInitialValues({
        'consultation_history':
            '[{"id":"a","timestamp":"2026-09-07T00:00:00.000",'
            '"symptoms":["cough"],"severities":{"cough":"catastrophic"}}]'
      });
      expect((await ConsultationHistoryService().load()).single.severities,
          isEmpty);
    });
  });

  group('provider', () {
    setUp(() async {
      await SymptomMatcherService().initialize();
    });

    test('severity is recorded for a confirmed symptom', () async {
      final provider = ConsultationProvider();
      await provider.submitInitialSymptoms(['high_fever']);
      await provider.answerFollowUpBatch(
        {'cough': true, 'fatigue': false},
        reportedSeverities: {'cough': SymptomSeverity.severe},
      );

      expect(provider.severities['cough'], SymptomSeverity.severe);
    });

    test('severity is ignored for a denied symptom', () async {
      final provider = ConsultationProvider();
      await provider.submitInitialSymptoms(['high_fever']);
      await provider.answerFollowUpBatch(
        {'cough': false},
        // Shouldn't happen from the UI, but must not be recorded if it does.
        reportedSeverities: {'cough': SymptomSeverity.severe},
      );

      expect(provider.severities, isEmpty);
      expect(provider.deniedSymptoms, contains('cough'));
    });

    test('answering without severity is fine', () async {
      final provider = ConsultationProvider();
      await provider.submitInitialSymptoms(['high_fever']);
      await provider.answerFollowUpBatch({'cough': true});

      expect(provider.symptoms, contains('cough'));
      expect(provider.severities, isEmpty);
    });

    test('severity does not change the prediction', () async {
      // The whole point: the classifier must not see this.
      final withoutSeverity = ConsultationProvider();
      await withoutSeverity.submitInitialSymptoms(['high_fever']);
      await withoutSeverity
          .answerFollowUpBatch({'cough': true, 'fatigue': true});

      final withSeverity = ConsultationProvider();
      await withSeverity.submitInitialSymptoms(['high_fever']);
      await withSeverity.answerFollowUpBatch(
        {'cough': true, 'fatigue': true},
        reportedSeverities: {
          'cough': SymptomSeverity.severe,
          'fatigue': SymptomSeverity.severe,
        },
      );

      expect(withSeverity.result!.topPrediction.disease,
          withoutSeverity.result!.topPrediction.disease);
      expect(withSeverity.result!.topPrediction.confidence,
          closeTo(withoutSeverity.result!.topPrediction.confidence, 1e-9),
          reason: 'severity is metadata and must not shift the model output');
    });

    test('reset clears severities', () async {
      final provider = ConsultationProvider();
      await provider.submitInitialSymptoms(['high_fever']);
      await provider.answerFollowUpBatch({'cough': true},
          reportedSeverities: {'cough': SymptomSeverity.mild});

      provider.reset();
      expect(provider.severities, isEmpty);
    });

    test('a new consultation clears the previous severities', () async {
      final provider = ConsultationProvider();
      await provider.submitInitialSymptoms(['high_fever']);
      await provider.answerFollowUpBatch({'cough': true},
          reportedSeverities: {'cough': SymptomSeverity.mild});

      await provider.submitInitialSymptoms(['headache']);
      expect(provider.severities, isEmpty);
    });
  });
}
