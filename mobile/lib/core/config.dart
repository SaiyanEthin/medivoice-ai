/// Centralized app-wide configuration.
/// Change values here rather than scattering them across files.
class AppConfig {
  // Android emulator's alias for your dev machine's localhost.
  // If running on a real device on the same WiFi, use your laptop's LAN IP instead,
  // e.g. "http://192.168.1.5:8000".
  // When you redeploy to Render (like the capstone project), swap this one line.
  static const String apiBaseUrl = "http://10.0.2.2:8000";

  // Matches backend/services/prediction_service.py CONFIDENCE_THRESHOLD
  static const double confidenceThreshold = 0.50;

  // Matches the 2-round cap used in backend/test_followup.py
  static const int maxFollowUpRounds = 2;

  static const Duration apiTimeout = Duration(seconds: 15);

  static const String appName = "MediVoice AI";
}
