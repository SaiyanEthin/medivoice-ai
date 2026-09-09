import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/disease_display.dart';
import '../l10n/app_localizations.dart';
import '../models/prediction_result.dart';
import '../widgets/follow_up_question_card.dart' show questionText;

/// Speaks the app's responses aloud using the device's own TTS engine.
///
/// No cloud voice service: this works with the network off, like the rest
/// of the app.
///
/// LANGUAGE: English only at present. The spoken content - question
/// templates, disease names, guidance - exists only in English, so setting
/// a Kannada or Hindi voice would read English words with the wrong
/// phonetics and produce nonsense. [speak] takes a locale so this can be
/// switched on per-language once those strings are translated.
class SpeechOutputService {
  static final SpeechOutputService _instance =
      SpeechOutputService._internal();
  factory SpeechOutputService() => _instance;
  SpeechOutputService._internal();

  static const _enabledKey = 'voice_guidance_enabled';
  static const _defaultLocale = 'en-US';

  final FlutterTts _tts = FlutterTts();

  /// On by default: reading aloud is the point of the feature, and the
  /// people it helps most are the least likely to go looking for a
  /// setting to turn it on.
  bool enabled = true;

  /// The locale the engine is currently configured for. Keyed on the
  /// locale rather than a plain bool: a single "ready" flag meant the
  /// first language of a session stuck, so switching language left the
  /// voice on the old one.
  String? _readyLocale;

  /// True when the engine reported that the requested voice isn't
  /// available, so callers can say so rather than leaving silence
  /// unexplained.
  bool voiceUnavailable = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      enabled = prefs.getBool(_enabledKey) ?? true;
    } catch (_) {
      // Keep the default rather than blocking startup.
    }
  }

  Future<void> setEnabled(bool value) async {
    enabled = value;
    if (!value) await stop();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, value);
    } catch (_) {
      // The toggle still works this session even if it can't persist.
    }
  }

  Future<void> _ensureReady(String locale) async {
    if (_readyLocale == locale) return;
    await _tts.setSpeechRate(0.45); // the default gabbles medical terms
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    final available = await _tts.isLanguageAvailable(locale);
    if (available == true) {
      await _tts.setLanguage(locale);
      voiceUnavailable = false;
    } else {
      voiceUnavailable = true;
    }
    _readyLocale = locale;
  }

  /// Speaks [text], interrupting anything already being spoken - a stale
  /// sentence finishing over a new question is worse than a cut-off word.
  Future<void> speak(String text, {String locale = _defaultLocale}) async {
    if (!enabled || text.trim().isEmpty) return;
    try {
      await _ensureReady(locale);
      if (voiceUnavailable) return;
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // A TTS failure must never interrupt the consultation.
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

// --- phrasing for listening -----------------------------------------------
//
// Spoken wording lives in the ARB files alongside the displayed wording,
// so a correction to one language updates screen and speech together.
// These helpers only choose WHICH string applies; they never contain any.

/// A result, phrased for the ear.
///
/// The percentage is rounded and spoken as a word: a voice cannot read the
/// % sign, and a decimal is easy to mishear.
String spokenResultText(AppText t, PredictionResult result) {
  if (result.isUncertain) return t.resultUncertainSpoken;
  return t.resultSpoken(
    diseaseDisplayName(result.topPrediction.disease),
    (result.topPrediction.confidence * 100).round(),
  );
}

/// A round of follow-up questions, read as one utterance so the voice
/// doesn't restart between them.
String spokenQuestionsText(AppText t, List<FollowUpQuestion> questions) {
  if (questions.isEmpty) return '';
  // The same resolved string the user is reading, so screen and
  // speech cannot diverge.
  final asked = questions.map((q) => questionText(t, q)).join(' ');
  return '${t.questionsSpokenIntro(questions.length)} $asked';
}
