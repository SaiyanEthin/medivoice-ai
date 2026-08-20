import '../services/api_service.dart';
import '../models/prediction_result.dart';
import '../models/advice.dart';
import '../models/doctor.dart';

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

  Future<List<Doctor>> getDoctors(String disease) {
    return _apiService.getDoctors(disease);
  }
}