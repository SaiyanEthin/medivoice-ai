import 'package:flutter/foundation.dart';
import '../models/prediction_result.dart';
import '../repositories/consultation_repository.dart';

enum ConsultationStatus { idle, loading, success, error }

/// Holds the state of a single consultation session: confirmed symptoms,
/// denied symptoms, current prediction, and the follow-up round counter.
///
/// NOTE: the follow-up round CAP lives in backend/config.py, not here.
/// This provider just tracks and reports the current round; the backend
/// decides when to stop asking. Single source of truth.
class ConsultationProvider extends ChangeNotifier {
  final ConsultationRepository _repository;

  ConsultationProvider({ConsultationRepository? repository})
      : _repository = repository ?? ConsultationRepository();

  final List<String> symptoms = [];
  final List<String> deniedSymptoms = [];
  int followUpRound = 0;

  ConsultationStatus status = ConsultationStatus.idle;
  PredictionResult? result;
  String? errorMessage;

  void reset() {
    symptoms.clear();
    deniedSymptoms.clear();
    followUpRound = 0;
    status = ConsultationStatus.idle;
    result = null;
    errorMessage = null;
    notifyListeners();
  }

   /// Starts a fresh consultation with the initial symptom list
  /// (e.g. parsed from the text stub or, later, Whisper transcription).
  /// [initialDenied] carries symptoms the user explicitly negated in their
  /// description ("I don't have a cough").
  Future<void> submitInitialSymptoms(
    List<String> initialSymptoms, {
    List<String> initialDenied = const [],
  }) async {
    symptoms.clear();
    deniedSymptoms.clear();
    followUpRound = 0;
    symptoms.addAll(initialSymptoms);
    deniedSymptoms.addAll(initialDenied);
    await _predict();
  }

  /// Applies a COMPLETE round of follow-up answers at once.
  ///
  /// The follow-up system generates a set of mutually-informative questions
  /// per round - they are chosen together, by coefficient variance across
  /// the current top candidates. Applying them one at a time threw that
  /// away: the round advanced after a single tap and the rest of the
  /// questions were discarded, so the real budget was 1 question per round
  /// regardless of AppConfig.questionsPerRound.
  ///
  /// [answers] maps symptom column -> true (present) / false (denied).
  /// Questions the user SKIPPED are simply absent from the map and are not
  /// recorded either way: not answering "do you have chest pain?" is not
  /// evidence that they don't.
  Future<void> answerFollowUpBatch(Map<String, bool> answers) async {
    answers.forEach((symptomColumn, answeredYes) {
      if (answeredYes) {
        symptoms.add(symptomColumn);
      } else {
        deniedSymptoms.add(symptomColumn);
      }
    });
    followUpRound++;
    await _predict();
  }

  /// Called when the user answers a follow-up question.
  @Deprecated('Ends the round after a single answer, discarding the other '
      'questions in the batch. Use answerFollowUpBatch() instead. Kept only '
      'so the regression test can document the original behaviour.')
  Future<void> answerFollowUp(String symptomColumn, bool answeredYes) async {
    if (answeredYes) {
      symptoms.add(symptomColumn);
    } else {
      deniedSymptoms.add(symptomColumn);
    }
    followUpRound++;
    await _predict();
  }

  Future<void> _predict() async {
    status = ConsultationStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      result = await _repository.getPrediction(
        symptoms: symptoms,
        deniedSymptoms: deniedSymptoms,
        followupRound: followUpRound,
      );
      status = ConsultationStatus.success;
    } catch (e) {
      status = ConsultationStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }
}