import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Converts free-text symptom descriptions (e.g. "I have fever and a cough")
/// into the model's symptom column names (e.g. ["high_fever", "cough"]).
///
/// This is NOT throwaway code for the text-input stub - Whisper's transcribed
/// text will flow through this exact same matcher later. Only the source of
/// the text changes (keyboard now, voice later); the matching logic is shared.
class SymptomMatcherService {
  static final SymptomMatcherService _instance = SymptomMatcherService._internal();
  factory SymptomMatcherService() => _instance;
  SymptomMatcherService._internal();

  Map<String, dynamic>? _dictionary;

  /// Phrase -> symptom column, sorted longest-phrase-first so "sore throat"
  /// matches before a shorter overlapping phrase would.
  List<MapEntry<String, String>> _phraseToColumn = [];

  Future<void> initialize() async {
    if (_dictionary != null) return; // already loaded

    final jsonString = await rootBundle.loadString('assets/data/symptom_dictionary.json');
    _dictionary = jsonDecode(jsonString) as Map<String, dynamic>;

    final entries = <MapEntry<String, String>>[];
    _dictionary!.forEach((column, data) {
      if (column.startsWith('_')) return; // skip the "_note" field
      final langs = data as Map<String, dynamic>;
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

  /// Returns the list of matched symptom column names found in [text].
  /// Case-insensitive, matches English/Hindi/Kannada phrases in the dictionary.
  List<String> matchSymptoms(String text) {
    if (_phraseToColumn.isEmpty) {
      throw StateError('SymptomMatcherService not initialized - call initialize() first');
    }

    final lowerText = text.toLowerCase();
    final matched = <String>{};

    for (final entry in _phraseToColumn) {
      if (lowerText.contains(entry.key)) {
        matched.add(entry.value);
      }
    }

    return matched.toList();
  }

  /// Reverse lookup for DISPLAY purposes: given a raw symptom column name
  /// (e.g. "high_fever"), return a readable English phrase (e.g. "fever").
  /// Used by the Prediction Screen's "Recognized Symptoms" list.
  /// Falls back to a readable version of the column name if not found.
  String getReadableLabel(String symptomColumn) {
    if (_dictionary == null) {
      return symptomColumn.replaceAll('_', ' ');
    }
    final entry = _dictionary![symptomColumn] as Map<String, dynamic>?;
    if (entry != null && entry['en'] is List && (entry['en'] as List).isNotEmpty) {
      return entry['en'][0].toString();
    }
    return symptomColumn.replaceAll('_', ' ');
  }
}
