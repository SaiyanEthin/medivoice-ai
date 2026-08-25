import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// On-device port of backend/services/advice_service.py.
/// Just a JSON lookup with a graceful fallback for unrecognized diseases -
/// no math involved, unlike DiseasePredictorService.
class AdviceService {
  Map<String, dynamic>? _adviceData;
  bool _loaded = false;

  Future<void> loadTemplates() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/advice_templates.json');
    _adviceData = jsonDecode(raw);
    _loaded = true;
  }

  /// Mirrors get_advice() in advice_service.py exactly, including the
  /// same fallback message for diseases with no template.
  Map<String, dynamic> getAdvice(String disease) {
    if (!_loaded) {
      throw StateError('AdviceService.loadTemplates() must be awaited before use.');
    }

    final trimmed = disease.trim();
    final entry = _adviceData![trimmed];

    if (entry == null) {
      return {
        'disease': trimmed,
        'severity': 'unknown',
        'advice': ['No advice template found for this disease. Please consult a physician.'],
      };
    }

    return {
      'disease': trimmed,
      'severity': entry['severity'],
      'advice': List<String>.from(entry['advice']),
    };
  }
}
