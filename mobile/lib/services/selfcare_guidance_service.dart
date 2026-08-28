import 'dart:convert';
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

    for (final entry in groups.entries) {
      final group = entry.value as Map<String, dynamic>;
      final groupSymptoms = List<String>.from(group['symptoms'] as List);
      if (groupSymptoms.any(symptomSet.contains)) {
        for (final line in List<String>.from(group['guidance'] as List)) {
          if (!bullets.contains(line)) bullets.add(line);
        }
      }
    }

    if (bullets.isEmpty) {
      bullets.addAll(List<String>.from(data['fallback_guidance'] as List));
    }

    return SelfCareGuidance(
      guidance: bullets,
      redFlags: List<String>.from(data['red_flags'] as List),
      disclaimer: data['disclaimer'] as String,
    );
  }
}
