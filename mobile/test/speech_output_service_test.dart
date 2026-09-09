import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/l10n/app_localizations.dart';
import 'package:medivoice_ai/l10n/app_localizations_en.dart';
import 'package:medivoice_ai/l10n/app_localizations_kn.dart';
import 'package:medivoice_ai/models/prediction_result.dart';
import 'package:medivoice_ai/services/symptom_matcher_service.dart';
import 'package:medivoice_ai/services/speech_output_service.dart';

PredictionResult _result({
  required String disease,
  required double confidence,
  bool uncertain = false,
}) {
  final top = DiseaseConfidence(disease: disease, confidence: confidence);
  return PredictionResult(
    topPrediction: top,
    allPredictions: [top],
    needsFollowup: false,
    followUpQuestions: const [],
    isUncertain: uncertain,
    uncertaintyReason: uncertain ? 'low_confidence' : null,
    followupRound: 1,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final AppText en = AppTextEn();
  final AppText kn = AppTextKn();

  group('spokenResultText', () {
    test('names the condition and rounds the score for the ear', () {
      final spoken = spokenResultText(
          en, _result(disease: 'Bronchial Asthma', confidence: 0.798));
      expect(spoken, contains('Bronchial Asthma'));
      expect(spoken, contains('80 percent'));
      expect(spoken, isNot(contains('%')),
          reason: 'a percent sign is not something a voice can read');
    });

    test('always says it is not a diagnosis', () {
      final spoken =
          spokenResultText(en, _result(disease: 'Migraine', confidence: 0.9));
      expect(spoken.toLowerCase(), contains('not a diagnosis'));
    });

    test('an uncertain result names no condition', () {
      final spoken = spokenResultText(
          en,
          _result(
              disease: 'Bronchial Asthma',
              confidence: 0.2,
              uncertain: true));
      expect(spoken, isNot(contains('Bronchial Asthma')),
          reason: 'the user was not shown a condition, so none is spoken');
    });

    test('the vertigo label is spoken in its cleaned form', () {
      final spoken = spokenResultText(
          en,
          _result(
              disease: '(vertigo) Paroymsal  Positional Vertigo',
              confidence: 0.8));
      expect(spoken, contains('Vertigo (BPPV)'));
      expect(spoken, isNot(contains('Paroymsal')),
          reason: 'the misspelled dataset label must not be read aloud');
    });

    test('Kannada produces Kannada, not the English string', () {
      final spoken = spokenResultText(
          kn, _result(disease: 'Bronchial Asthma', confidence: 0.8));
      expect(spoken, isNot(contains('pattern match')));
      expect(spoken, contains('Bronchial Asthma'),
          reason: 'disease names are not translated yet, so they carry '
              'through unchanged');
    });
  });

  group('spokenQuestionsText', () {
    // Question text is rendered from the localised template plus the
    // symptom column. The `question` field on FollowUpQuestion is built
    // by the orchestrator in English and is deliberately not used for
    // display or speech.
    setUpAll(() async {
      await SymptomMatcherService().initialize();
    });

    test('reads a round as one utterance', () {
      final spoken = spokenQuestionsText(en, [
        FollowUpQuestion(
            symptom: 'fatigue', question: 'ignored'),
        FollowUpQuestion(symptom: 'cough', question: 'ignored'),
      ]);
      expect(spoken, contains('2 quick questions'));
      expect(spoken, contains('fatigue'));
      expect(spoken, contains('cough'));
    });

    test('the pre-built question string is not used', () {
      final spoken = spokenQuestionsText(en, [
        FollowUpQuestion(
            symptom: 'fatigue',
            question: 'THIS SHOULD NOT BE SPOKEN'),
      ]);
      expect(spoken, isNot(contains('THIS SHOULD NOT BE SPOKEN')),
          reason: 'the orchestrator builds that field in English; speech '
              'must come from the localised template');
    });

    test('uses the singular for one question', () {
      final spoken = spokenQuestionsText(en, [
        FollowUpQuestion(symptom: 'fatigue', question: 'ignored'),
      ]);
      expect(spoken, contains('1 quick question.'));
    });

    test('the template follows the app language', () {
      final questions = [
        FollowUpQuestion(symptom: 'fatigue', question: 'ignored'),
      ];
      final english = spokenQuestionsText(en, questions);
      final kannada = spokenQuestionsText(kn, questions);

      expect(english, contains('Do you have'));
      expect(kannada, isNot(contains('Do you have')),
          reason: 'the question template was hardcoded English until the '
              'device test caught it');
      // The symptom name stays English until symptom labels are
      // translated, so both should still contain it.
      expect(kannada, contains('fatigue'));
    });

    test('an empty round produces nothing to say', () {
      expect(spokenQuestionsText(en, []), isEmpty);
    });
  });

  group('translations are present', () {
    test('consultation strings differ between English and Kannada', () {
      // Catches a key silently falling back to English.
      final pairs = <String, List<String>>{
        'consultGreeting': [en.consultGreeting, kn.consultGreeting],
        'consultRestart': [en.consultRestart, kn.consultRestart],
        'questionsTitle': [en.questionsTitle, kn.questionsTitle],
        'answerYes': [en.answerYes, kn.answerYes],
        'answerNo': [en.answerNo, kn.answerNo],
        'actionContinue': [en.actionContinue, kn.actionContinue],
        'severityMild': [en.severityMild, kn.severityMild],
        'resultUncertainTitle': [
          en.resultUncertainTitle,
          kn.resultUncertainTitle
        ],
      };
      pairs.forEach((key, values) {
        expect(values[0], isNot(values[1]),
            reason: '$key appears untranslated in Kannada');
      });
    });

    test('the app name is deliberately the same in every language', () {
      expect(kn.appTitle, en.appTitle);
    });
  });
}
