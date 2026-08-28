import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Result of analyzing a free-text symptom description.
class SymptomAnalysis {
  final List<String> present;  // symptoms the user says they HAVE
  final List<String> denied;   // symptoms the user explicitly says they DON'T have

  SymptomAnalysis({required this.present, required this.denied});

  bool get isEmpty => present.isEmpty && denied.isEmpty;
}

/// Converts free-text symptom descriptions into the model's symptom column
/// names. Handles conversational input ("hey, I think I have...") by simply
/// ignoring anything that isn't a known symptom phrase.
///
/// Also detects negation: "I don't have a cough" routes cough to the DENIED
/// list rather than the present list, so it counts as evidence AGAINST
/// cough-related conditions instead of being wrongly added or silently lost.
///
/// This is NOT throwaway code for the text-input stub - Whisper's transcribed
/// text will flow through this exact same matcher later. Only the source of
/// the text changes (keyboard now, voice later).
class SymptomMatcherService {
  static final SymptomMatcherService _instance = SymptomMatcherService._internal();
  factory SymptomMatcherService() => _instance;
  SymptomMatcherService._internal();

  Map<String, dynamic>? _dictionary;
  List<MapEntry<String, String>> _phraseToColumn = [];

  /// Phrase-level suppression. When one of these phrases appears in a
  /// clause, the listed columns are blocked FOR THAT CLAUSE ONLY.
  ///
  /// Needed because matching is plain substring containment, so a short
  /// phrase can fire inside an unrelated longer one:
  ///   "rash" (skin_rash) inside "gale mein kharash" (throat_irritation)
  ///   "vomiting" (vomiting) inside "feeling like vomiting" (nausea)
  ///
  /// Deliberately an explicit opt-in list rather than a general
  /// longest-phrase-wins rule: a general rule would also stop
  /// "coughing up blood" from crediting cough, which is not wanted.
  Map<String, List<String>> _matchOverrides = {};

  /// Negation cues across our three supported languages.
  static const List<String> _negationCues = [
    'not', 'no ', 'never', 'without',
    "don't", 'dont', "doesn't", 'doesnt', "didn't", 'didnt',
    "haven't", 'havent', "hasn't", 'hasnt', "isn't", 'isnt',
    'nahi', 'नहीं', 'नही',          // Hindi
    'illa', 'ಇಲ್ಲ',                  // Kannada
  ];

  /// Splits a sentence into clauses so negation only applies to its own clause.
  /// "fever, but no cough" -> ["fever", " no cough"]
  static final RegExp _clauseSplitter =
      RegExp(r'[,;.]|\bbut\b|\bthough\b|\bhowever\b|\bexcept\b');

  Future<void> initialize() async {
    if (_dictionary != null) return;

    final jsonString = await rootBundle.loadString('assets/data/symptom_dictionary.json');
    _dictionary = jsonDecode(jsonString) as Map<String, dynamic>;

    final overrides = _dictionary!['_match_overrides'] as Map<String, dynamic>?;
    _matchOverrides = {};
    if (overrides != null) {
      overrides.forEach((phrase, cols) {
        _matchOverrides[phrase.toString().toLowerCase()] =
            List<String>.from(cols as List);
      });
    }

    final entries = <MapEntry<String, String>>[];
    _dictionary!.forEach((column, data) {
      if (column.startsWith('_')) return; // skip the "_note" field
      final langs = data as Map<String, dynamic>;
      // Entries flagged "match": false supply a readable label for follow-up
      // questions WITHOUT becoming free-text match targets. Used for
      // background/history features (family_history), third-person
      // observations (toxic_look_(typhos)), and concepts a user would not
      // naturally volunteer aloud (internal_itching).
      if (langs['match'] == false) return;
      for (final lang in ['en', 'hi', 'kn']) {
        final phrases = (langs[lang] as List<dynamic>?) ?? [];
        for (final phrase in phrases) {
          entries.add(MapEntry(phrase.toString().toLowerCase(), column));
        }
      }
    });

    // Longest phrases first so multi-word phrases win over short substrings
    entries.sort((a, b) => b.key.length.compareTo(a.key.length));
    _phraseToColumn = entries;
  }

  /// Analyzes free text, separating confirmed-present from explicitly-denied
  /// symptoms. Unknown words are ignored, so conversational filler is harmless.
  SymptomAnalysis analyze(String text) {
    if (_phraseToColumn.isEmpty) {
      throw StateError('SymptomMatcherService not initialized - call initialize() first');
    }

    final lower = text.toLowerCase();
    final present = <String>[];
    final denied = <String>[];

    for (final clause in lower.split(_clauseSplitter)) {
      if (clause.trim().isEmpty) continue;

      final isNegated = _negationCues.any((cue) => clause.contains(cue));

      // Columns blocked for this clause because a more specific phrase
      // containing them as a substring is present (see _matchOverrides).
      final blocked = <String>{};
      _matchOverrides.forEach((phrase, cols) {
        if (clause.contains(phrase)) blocked.addAll(cols);
      });

      for (final entry in _phraseToColumn) {
        if (!clause.contains(entry.key)) continue;
        final column = entry.value;
        if (blocked.contains(column)) continue;
        // First mention wins - don't let a later clause flip an earlier decision
        if (present.contains(column) || denied.contains(column)) continue;
        (isNegated ? denied : present).add(column);
      }
    }

    return SymptomAnalysis(present: present, denied: denied);
  }

  /// Kept for backwards compatibility / simple cases where negation
  /// handling isn't needed. Returns only the present symptoms.
  List<String> matchSymptoms(String text) => analyze(text).present;

  /// Reverse lookup for DISPLAY purposes: given a raw symptom column name
  /// (e.g. "high_fever"), return a readable English phrase (e.g. "fever").
  String getReadableLabel(String symptomColumn) {
    if (_dictionary == null) {
      return symptomColumn.replaceAll('_', ' ');
    }
    final entry = _dictionary![symptomColumn] as Map<String, dynamic>?;
    if (entry != null) {
      // Prefer an explicit display label. Natural voice phrases read badly
      // in the follow-up template ("Do you have room is spinning?"), so
      // entries carry a separate grammatical label for display.
      final label = entry['label'];
      if (label is String && label.isNotEmpty) return label;
      if (entry['en'] is List && (entry['en'] as List).isNotEmpty) {
        return entry['en'][0].toString();
      }
    }
    return symptomColumn.replaceAll('_', ' ');
  }
}