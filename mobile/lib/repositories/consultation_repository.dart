import '../services/api_service.dart';
import '../models/prediction_result.dart';
import '../models/advice.dart';

/// Sits between Provider and ApiService. Today it just forwards to the
/// backend, but when we move to offline inference, ONLY this file changes -
/// ApiService gets swapped for on-device weight-matrix math, and
/// ConsultationProvider never has to know the difference.
class ConsultationRepository {
  final ApiService _apiService;

  ConsultationRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<PredictionResult> getPrediction({
    required List<String> symptoms,
    List<String> deniedSymptoms = const [],
    int followupRound = 0,
  }) {
    return _apiService.predict(
      symptoms: symptoms,
      deniedSymptoms: deniedSymptoms,
      followupRound: followupRound,
    );
  }

  Future<Advice> getAdvice(String disease) {
    return _apiService.getAdvice(disease);
  }

  Future<List<dynamic>> getDoctors(String disease) {
    return _apiService.getDoctors(disease);
  }
}