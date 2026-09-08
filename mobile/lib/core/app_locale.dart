import 'package:flutter/widgets.dart';
import '../services/language_prefs_service.dart';

/// The language the app is displayed and spoken in.
///
/// Reuses the preference the user already picks on first run - choosing
/// "I speak Kannada" should mean the whole app is Kannada, not just the
/// speech recogniser.
///
/// A ValueNotifier so changing it rebuilds MaterialApp with the new
/// locale, without pulling in a state-management package.
class AppLocale extends ValueNotifier<Locale> {
  static final AppLocale _instance = AppLocale._internal();
  factory AppLocale() => _instance;
  AppLocale._internal() : super(const Locale('en'));

  /// 'auto' is a per-recording option in the consultation screen, not a
  /// UI language, so it never reaches here.
  static const supportedCodes = ['en', 'kn', 'hi'];

  Future<void> load() async {
    try {
      final code = await LanguagePrefsService().getPreferredLanguage();
      if (code != null && supportedCodes.contains(code)) {
        value = Locale(code);
      }
    } catch (_) {
      // English is a safe fallback.
    }
  }

  Future<void> set(String code) async {
    if (!supportedCodes.contains(code)) return;
    await LanguagePrefsService().setPreferredLanguage(code);
    value = Locale(code);
  }

  /// The BCP-47 tag for text-to-speech.
  String get ttsLocale {
    switch (value.languageCode) {
      case 'kn':
        return 'kn-IN';
      case 'hi':
        return 'hi-IN';
      default:
        return 'en-US';
    }
  }
}
