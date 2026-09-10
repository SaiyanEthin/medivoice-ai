import 'dart:convert';
import '../core/app_locale.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Result of a self-care lookup.
class SelfCareGuidance {
  final List<String> guidance;
  final List<String> redFlags;
  final String disclaimer;

  const SelfCareGuidance({
    required this.guidance,
    required this.redFlags,
    required this.disclaimer,
  });
}

/// Rule-based, fully offline supportive guidance for the "Symptoms Unclear"
/// case. Deliberately NOT a classifier and NOT an emergency detector: it
/// maps already-extracted symptom columns to comfort measures, and always
/// returns the same static red-flag list regardless of input.
///
/// Singleton so the result screen (a StatelessWidget) can read it
/// synchronously after VoiceInputScreen initializes it, matching the
/// existing SymptomMatcherService pattern.
class SelfCareGuidanceService {
  static final SelfCareGuidanceService _instance =
      SelfCareGuidanceService._internal();
  factory SelfCareGuidanceService() => _instance;
  SelfCareGuidanceService._internal();

  Map<String, dynamic>? _data;

  bool get isLoaded => _data != null;

  Future<void> initialize() async {
    if (_data != null) return;
    final raw = await rootBundle.loadString('assets/data/selfcare_guidance.json');
    _data = jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Returns guidance for the given symptom columns, or null if the asset
  /// hasn't loaded - callers fall back to their own static text rather than
  /// rendering an empty card.
  ///
  /// Groups are included when at least one of their symptoms is present.
  /// Bullets are de-duplicated across groups (some symptoms deliberately
  /// belong to more than one group) while preserving declaration order.
  SelfCareGuidance? guidanceFor(List<String> symptoms) {
    final data = _data;
    if (data == null) return null;

    final groups = data['groups'] as Map<String, dynamic>;
    final symptomSet = symptoms.toSet();
    final bullets = <String>[];

    // Caps. Without them a broad symptom set matched four groups and
    // produced ~13 bullets, which is a wall of text for someone who is
    // already unwell.
    const maxPerGroup = 2;
    const maxTotal = 8;

    final matchedGroups = <List<String>>[];
    for (final entry in groups.entries) {
      final group = entry.value as Map<String, dynamic>;
      final groupSymptoms = List<String>.from(group['symptoms'] as List);
      if (groupSymptoms.any(symptomSet.contains)) {
        matchedGroups.add(_localisedList(group, 'guidance'));
      }
    }

    // Round-robin: one bullet from every matched group, then a second from
    // every group. Draining each group in turn would let the first groups
    // consume the total cap and drop later ones entirely.
    for (var pass = 0; pass < maxPerGroup; pass++) {
      for (final groupLines in matchedGroups) {
        if (bullets.length >= maxTotal) break;
        if (pass >= groupLines.length) continue;
        final line = groupLines[pass];
        if (!bullets.contains(line)) bullets.add(line);
      }
    }

    if (bullets.isEmpty) {
      bullets.addAll(_localisedList(data, 'fallback_guidance'));
    }

    return SelfCareGuidance(
      guidance: bullets,
      redFlags: _localisedList(data, 'red_flags'),
      disclaimer: _localisedString(data, 'disclaimer'),
    );
  }
}

/// A list in the app's language, falling back to English.
///
/// Kept per language rather than translated at runtime: the red flags in
/// particular are the strings that tell someone to go to a hospital, and
/// a correction to their wording should happen in one reviewed place.
List<String> _localisedList(Map<String, dynamic> source, String key) {
  final code = UnitPrefsLocale.code;
  if (code != 'en') {
    final localised = source['${key}_$code'];
    if (localised is List && localised.isNotEmpty) {
      return List<String>.from(localised);
    }
  }
  return List<String>.from(source[key] as List);
}

String _localisedString(Map<String, dynamic> source, String key) {
  final code = UnitPrefsLocale.code;
  if (code != 'en') {
    final localised = source['${key}_$code'];
    if (localised is String && localised.isNotEmpty) return localised;
  }
  return source[key] as String;
}

/// Thin indirection so this file doesn't import a widget-layer type.
class UnitPrefsLocale {
  static String get code => AppLocale().value.languageCode;
}
