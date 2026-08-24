import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's preferred consultation language across app
/// restarts. Chosen once during first-run language selection; can be
/// overridden per-recording on the voice input screen itself without
/// changing this saved default.
class LanguagePrefsService {
  static const _key = 'preferred_language';

  /// Supported language codes match what SpeechService/whisper_ggml expect:
  /// 'kn' (Kannada), 'hi' (Hindi), 'en' (English).
  Future<String?> getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> setPreferredLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }

  Future<bool> hasPreference() async {
    final lang = await getPreferredLanguage();
    return lang != null;
  }
}
