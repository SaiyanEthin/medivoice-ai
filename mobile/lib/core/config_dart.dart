/// Centralized app-wide configuration.
/// Change values here rather than scattering them across files.
class AppConfig {
  // --- Legacy HTTP config, kept for reference / rollback only ---
  // No longer used once ConsultationRepository was switched to the
  // on-device services (DiseasePredictorService, AdviceService,
  // DoctorService). Safe to delete once that switch is confirmed stable.
  static const String apiBaseUrl = "http://192.168.1.7:8000";
  static const Duration apiTimeout = Duration(seconds: 15);

  // Mirrors backend/config.py exactly - this MUST stay in sync with that
  // file's values, since the Dart prediction orchestrator was ported from
  // it directly and is meant to behave identically.
  //
  // CORRECTED 2026-08-25: this was previously 0.50, but backend/config.py
  // actually uses 0.65 - the two had drifted out of sync at some point.
  static const double confidenceThreshold = 0.65;
  static const int minSymptomsForPrediction = 3;
  static const int maxFollowUpRounds = 2;
  static const int questionsPerRound = 3;

  static const String appName = "MediVoice AI";
}
