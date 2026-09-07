import 'package:flutter_test/flutter_test.dart';
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
  group('spokenResult', () {
    test('names the condition and rounds the score for the ear', () {
      final spoken = spokenResult(
          _result(disease: 'Bronchial Asthma', confidence: 0.798));
      expect(spoken, contains('Bronchial Asthma'));
      expect(spoken, contains('80 percent'));
      expect(spoken, isNot(contains('%')),
          reason: 'a percent sign is not something a voice can read');
    });

    test('always says it is not a diagnosis', () {
      final spoken =
          spokenResult(_result(disease: 'Migraine', confidence: 0.9));
      expect(spoken.toLowerCase(), contains('not a diagnosis'));
    });

    test('an uncertain result names no condition', () {
      final spoken = spokenResult(_result(
          disease: 'Bronchial Asthma', confidence: 0.2, uncertain: true));
      expect(spoken, isNot(contains('Bronchial Asthma')),
          reason: 'the user was not shown a condition, so none is spoken');
      expect(spoken.toLowerCase(), contains("not confident enough"));
    });

    test('the vertigo label is spoken in its cleaned form', () {
      final spoken = spokenResult(_result(
          disease: '(vertigo) Paroymsal  Positional Vertigo',
          confidence: 0.8));
      expect(spoken, contains('Vertigo (BPPV)'));
      expect(spoken, isNot(contains('Paroymsal')),
          reason: 'the misspelled dataset label must not be read aloud');
    });
  });

  group('spokenQuestions', () {
    test('reads a round as one utterance', () {
      final spoken = spokenQuestions([
        FollowUpQuestion(symptom: 'fatigue', question: 'Do you have fatigue?'),
        FollowUpQuestion(
            symptom: 'cough', question: 'Do you have a cough?'),
      ]);
      expect(spoken, contains('2 quick questions'));
      expect(spoken, contains('Do you have fatigue?'));
      expect(spoken, contains('Do you have a cough?'));
    });

    test('uses the singular for one question', () {
      final spoken = spokenQuestions([
        FollowUpQuestion(symptom: 'fatigue', question: 'Do you have fatigue?'),
      ]);
      expect(spoken, contains('1 quick question.'));
      expect(spoken, isNot(contains('questions')));
    });

    test('an empty round produces nothing to say', () {
      expect(spokenQuestions([]), isEmpty);
    });
  });
}
