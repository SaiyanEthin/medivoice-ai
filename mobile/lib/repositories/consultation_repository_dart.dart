import '../models/prediction_result.dart';
import '../models/advice.dart';
import '../models/doctor.dart';
import '../services/advice_service_dart.dart';
import '../services/consultation_orchestrator_service.dart';
import '../services/doctor_service_dart.dart';

/// Now backed by on-device services instead of ApiService/HTTP.
/// The public interface is UNCHANGED from the HTTP version - same method
/// names, same signatures, same return types - so ConsultationProvider
/// (and everything above it) needed zero changes for this swap. This is
/// exactly the seam this class was designed around from the start.
class ConsultationRepository {
  final ConsultationOrchestratorService _orchestrator;
  final AdviceService _adviceService;
  final DoctorService _doctorService;
  bool _initialized = false;

  ConsultationRepository({
    ConsultationOrchestratorService? orchestrator,
    AdviceService? adviceService,
    DoctorService? doctorService,
  })  : _orchestrator = orchestrator ?? ConsultationOrchestratorService(),
        _adviceService = adviceService ?? AdviceService(),
        _doctorService = doctorService ?? DoctorService();

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _orchestrator.loadModel();
    await _adviceService.loadTemplates();
    await _doctorService.loadDoctors();
    _initialized = true;
  }

  Future<PredictionResult> getPrediction({
    required List<String> symptoms,
    List<String> deniedSymptoms = const [],
    int followupRound = 0,
  }) async {
    await _ensureInitialized();
    return _orchestrator.predict(
      symptoms: symptoms,
      deniedSymptoms: deniedSymptoms,
      followupRound: followupRound,
    );
  }

  Future<Advice> getAdvice(String disease) async {
    await _ensureInitialized();
    final raw = _adviceService.getAdvice(disease);
    return Advice(
      disease: raw['disease'] as String,
      severity: raw['severity'] as String,
      advice: List<String>.from(raw['advice']),
    );
  }

  Future<List<Doctor>> getDoctors(String disease) async {
    await _ensureInitialized();
    final raw = _doctorService.getDoctorsForDisease(disease);
    return raw
        .map((d) => Doctor(
              name: d['name'] as String,
              specialization: d['specialization'] as String,
              district: d['district'] as String,
              phone: d['phone'] as String,
              distanceKm: (d['distance_km'] as num).toDouble(),
            ))
        .toList();
  }
}
