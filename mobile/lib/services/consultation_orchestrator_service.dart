import '../core/config.dart';
import '../models/prediction_result.dart';
import 'disease_predictor_service.dart';
import 'symptom_matcher_service.dart';

/// On-device port of backend/api/predict.py's decision logic.
///
/// The Python endpoint did three things: (1) validate the request,
/// (2) run the model, (3) decide whether to ask a follow-up question or
/// commit to an answer, via two gates. This class ports (2) and (3).
/// Validation (1) is dropped - symptoms only ever arrive here already
/// normalized by SymptomMatcherService, so there's no untrusted input
/// boundary to guard anymore (that was HTTP's job, not this method's).
///
/// GATE 1 (minimum evidence): too few confirmed-present symptoms to say
/// anything meaningful, regardless of model confidence - ask broadly
/// informative questions instead of guessing from 1-2 symptoms.
///
/// GATE 2 (confidence): if the top prediction's probability is still below
/// threshold even with enough symptoms, ask distinguishing questions
/// between the top 3 candidates instead of naming a shaky answer.
///
/// Both gates stop asking once maxFollowUpRounds is reached and report
/// "uncertain" rather than a low-confidence guess.
class ConsultationOrchestratorService {
  final DiseasePredictorService _predictor;
  final SymptomMatcherService _matcher;

  ConsultationOrchestratorService({
    DiseasePredictorService? predictor,
    SymptomMatcherService? matcher,
  })  : _predictor = predictor ?? DiseasePredictorService(),
        _matcher = matcher ?? SymptomMatcherService();

  Future<void> loadModel() => _predictor.loadModel();

  PredictionResult predict({
    required List<String> symptoms,
    List<String> deniedSymptoms = const [],
    int followupRound = 0,
  }) {
    final rawResult = _predictor.predict(symptoms, deniedSymptoms: deniedSymptoms);
    final topConfidence = (rawResult['top_prediction'] as Map)['confidence'] as double;
    final alreadyAnswered = [...symptoms, ...deniedSymptoms];
    final roundsRemaining = followupRound < AppConfig.maxFollowUpRounds;

    // --- GATE 1: MINIMUM EVIDENCE ---
    if (symptoms.length < AppConfig.minSymptomsForPrediction) {
      if (roundsRemaining) {
        final questions = _predictor.getInformativeSymptoms(
          alreadyAnswered,
          n: AppConfig.questionsPerRound,
        );
        if (questions.isNotEmpty) {
          return _buildResult(rawResult, true, questions, false, null, followupRound);
        }
      }
      return _buildResult(rawResult, false, [], true, 'insufficient_symptoms', followupRound);
    }

    // --- GATE 2: CONFIDENCE ---
    if (topConfidence < AppConfig.confidenceThreshold) {
      if (roundsRemaining) {
        final top3 = (rawResult['all_predictions'] as List)
            .take(3)
            .map((p) => (p as Map)['disease'] as String)
            .toList();
        final questions = _predictor.getDistinguishingSymptoms(
          top3,
          alreadyAnswered,
          n: AppConfig.questionsPerRound,
        );
        if (questions.isNotEmpty) {
          return _buildResult(rawResult, true, questions, false, null, followupRound);
        }
      }
      return _buildResult(rawResult, false, [], true, 'low_confidence', followupRound);
    }

    // --- Confident enough, and enough evidence ---
    return _buildResult(rawResult, false, [], false, null, followupRound);
  }

  PredictionResult _buildResult(
    Map rawResult,
    bool needsFollowup,
    List<String> questionColumns,
    bool isUncertain,
    String? uncertaintyReason,
    int round,
  ) {
    final allPredictions = (rawResult['all_predictions'] as List)
        .map((p) => DiseaseConfidence(
              disease: (p as Map)['disease'] as String,
              confidence: (p['confidence'] as num).toDouble(),
            ))
        .toList();

    // Mirrors question_service.symptom_to_question() - "Do you have X?"
    // built from SymptomMatcherService's existing dictionary lookup.
    final followUpQuestions = questionColumns
        .map((col) => FollowUpQuestion(
              symptom: col,
              question: 'Do you have ${_matcher.getReadableLabel(col)}?',
            ))
        .toList();

    return PredictionResult(
      topPrediction: allPredictions.first,
      allPredictions: allPredictions,
      needsFollowup: needsFollowup,
      followUpQuestions: followUpQuestions,
      isUncertain: isUncertain,
      uncertaintyReason: uncertaintyReason,
      followupRound: round,
    );
  }
}
