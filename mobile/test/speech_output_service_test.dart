import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/l10n/app_localizations.dart';
import 'package:medivoice_ai/l10n/app_localizations_en.dart';
import 'package:medivoice_ai/l10n/app_localizations_kn.dart';
import 'package:medivoice_ai/models/prediction_result.dart';
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
    test('reads a round as one utterance', () {
      final spoken = spokenQuestionsText(en, [
        FollowUpQuestion(
            symptom: 'fatigue', question: 'Do you have fatigue?'),
        FollowUpQuestion(symptom: 'cough', question: 'Do you have a cough?'),
      ]);
      expect(spoken, contains('2 quick questions'));
      expect(spoken, contains('Do you have fatigue?'));
      expect(spoken, contains('Do you have a cough?'));
    });

    test('uses the singular for one question', () {
      final spoken = spokenQuestionsText(en, [
        FollowUpQuestion(
            symptom: 'fatigue', question: 'Do you have fatigue?'),
      ]);
      expect(spoken, contains('1 quick question.'));
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
