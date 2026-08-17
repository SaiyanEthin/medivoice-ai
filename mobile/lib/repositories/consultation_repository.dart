import '../services/api_service.dart';
import '../models/prediction_result.dart';

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
  }) {
    return _apiService.predict(symptoms: symptoms, deniedSymptoms: deniedSymptoms);
  }

  Future<Map<String, dynamic>> getAdvice(String disease) {
    return _apiService.getAdvice(disease);
  }

  Future<List<dynamic>> getDoctors(String disease) {
    return _apiService.getDoctors(disease);
  }
}
