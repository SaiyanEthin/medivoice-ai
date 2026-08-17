import 'package:flutter/foundation.dart';
import '../core/config.dart';
import '../models/prediction_result.dart';
import '../repositories/consultation_repository.dart';

enum ConsultationStatus { idle, loading, success, error }

/// Holds the state of a single consultation session: confirmed symptoms,
/// denied symptoms, current prediction, and the follow-up round counter.
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
  Future<void> submitInitialSymptoms(List<String> initialSymptoms) async {
    symptoms.clear();
    deniedSymptoms.clear();
    followUpRound = 0;
    symptoms.addAll(initialSymptoms);
    await _predict();
  }

  /// Called when the user answers a follow-up question.
  Future<void> answerFollowUp(String symptomColumn, bool answeredYes) async {
    if (answeredYes) {
      symptoms.add(symptomColumn);
    } else {
      deniedSymptoms.add(symptomColumn);
    }
    followUpRound++;
    await _predict();
  }

  bool get canAskMoreFollowUps => followUpRound < AppConfig.maxFollowUpRounds;

  Future<void> _predict() async {
    status = ConsultationStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final prediction = await _repository.getPrediction(
        symptoms: symptoms,
        deniedSymptoms: deniedSymptoms,
      );

      // Respect the round cap even if the backend still thinks it needs more -
      // after maxFollowUpRounds, show the current top predictions regardless.
      if (prediction.needsFollowup && !canAskMoreFollowUps) {
        result = PredictionResult(
          topPrediction: prediction.topPrediction,
          allPredictions: prediction.allPredictions,
          needsFollowup: false,
          followUpQuestions: [],
        );
      } else {
        result = prediction;
      }

      status = ConsultationStatus.success;
    } catch (e) {
      status = ConsultationStatus.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }
}
