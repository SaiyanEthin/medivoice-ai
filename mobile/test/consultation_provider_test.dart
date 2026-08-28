import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/providers/consultation_provider.dart';
import 'package:medivoice_ai/services/symptom_matcher_service.dart';

/// Regression tests for the follow-up batching fix.
///
/// The bug: FollowUpQuestionCard rendered N questions, but each Yes/No
/// button called answerFollowUp() directly, which incremented the round and
/// re-predicted immediately. The remaining questions were discarded, so the
/// real budget was 1 answer per round no matter what questionsPerRound said.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SymptomMatcherService().initialize();
  });

  group('the original single-answer behaviour (documents the bug)', () {
    test('one answer advanced the round on its own', () async {
      final p = ConsultationProvider();
      await p.submitInitialSymptoms(['high_fever']);
      expect(p.followUpRound, 0);

      // ignore: deprecated_member_use_from_same_package
      await p.answerFollowUp('fatigue', true);

      expect(p.followUpRound, 1,
          reason: 'a single answer ended the round - this is why batching '
              'was needed; the other questions in the batch were lost');
    });
  });

  group('batch submission', () {
    test('a whole round of answers advances the round exactly once', () async {
      final p = ConsultationProvider();
      await p.submitInitialSymptoms(['high_fever']);
      expect(p.followUpRound, 0);

      await p.answerFollowUpBatch({
        'fatigue': true,
        'muscle_pain': false,
        'diarrhoea': true,
      });

      expect(p.followUpRound, 1,
          reason: 'three answers must count as ONE round, not three');
    });

    test('every answer in the batch is applied before re-prediction', () async {
      final p = ConsultationProvider();
      await p.submitInitialSymptoms(['high_fever']);

      await p.answerFollowUpBatch({
        'fatigue': true,
        'muscle_pain': false,
        'diarrhoea': true,
        'headache': false,
      });

      expect(p.symptoms, containsAll(['high_fever', 'fatigue', 'diarrhoea']));
      expect(p.deniedSymptoms, containsAll(['muscle_pain', 'headache']));
    });

    test('skipped questions are ignored, NOT recorded as denied', () async {
      final p = ConsultationProvider();
      await p.submitInitialSymptoms(['high_fever']);

      // 'chest_pain' was shown but left unanswered, so it is absent here.
      await p.answerFollowUpBatch({'fatigue': true, 'muscle_pain': false});

      expect(p.symptoms, contains('fatigue'));
      expect(p.deniedSymptoms, contains('muscle_pain'));
      expect(p.deniedSymptoms, isNot(contains('chest_pain')),
          reason: 'not answering is not evidence of absence');
      expect(p.symptoms, isNot(contains('chest_pain')));
    });

    test('two rounds of batches reach round 2, not round 6', () async {
      final p = ConsultationProvider();
      await p.submitInitialSymptoms(['high_fever']);

      await p.answerFollowUpBatch(
          {'fatigue': true, 'muscle_pain': false, 'diarrhoea': false});
      await p.answerFollowUpBatch(
          {'headache': true, 'nausea': false, 'chills': true});

      expect(p.followUpRound, 2,
          reason: 'six answers across two rounds must count as two rounds');
    });

    test('accumulated evidence sharpens the prediction', () async {
      final p = ConsultationProvider();
      await p.submitInitialSymptoms(['high_fever', 'cough']);
      final before = p.result?.topPrediction.confidence ?? 0;

      await p.answerFollowUpBatch(
          {'fatigue': true, 'breathlessness': true, 'phlegm': true});
      final after = p.result?.topPrediction.confidence ?? 0;

      expect(after, greaterThan(before),
          reason: 'confirming three more symptoms should raise confidence');
    });

    test('reset() clears the round counter and both symptom lists', () async {
      final p = ConsultationProvider();
      await p.submitInitialSymptoms(['high_fever']);
      await p.answerFollowUpBatch({'fatigue': true, 'muscle_pain': false});

      p.reset();

      expect(p.followUpRound, 0);
      expect(p.symptoms, isEmpty);
      expect(p.deniedSymptoms, isEmpty);
      expect(p.status, ConsultationStatus.idle);
    });
  });
}
