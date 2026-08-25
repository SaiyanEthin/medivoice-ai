import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;

/// On-device port of backend/services/prediction_service.py.
///
/// The original model is a scikit-learn LogisticRegression trained with
/// no explicit solver/multi_class (LogisticRegression(max_iter=1000)).
/// On the sklearn version this was trained with, that default is
/// SOFTMAX (multinomial) - all classes are scored jointly and normalized
/// together - NOT one-vs-rest. Getting this right matters: OvR would
/// silently produce different percentages than the Python backend did.
///
/// Math per disease:
///   score = (weights · symptom_vector) + intercept
/// Then softmax across all diseases' scores -> percentages summing to 100%.
///
/// This class deliberately mirrors the Python file's structure and public
/// shape (top_prediction / all_predictions) so nothing above it needs to
/// change - same pattern already used for api_service.dart.
class DiseasePredictorService {
  List<String>? _classes;
  List<String>? _symptomColumns;
  List<List<double>>? _coefficients; // [class][symptom]
  List<double>? _intercepts; // [class]
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<String> get symptomColumns => _symptomColumns ?? const [];

  Future<void> loadModel() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/lr_model_weights.json');
    final Map<String, dynamic> data = jsonDecode(raw);

    _classes = List<String>.from(data['classes']);
    _symptomColumns = List<String>.from(data['symptom_columns']);
    _coefficients = (data['coefficients'] as List)
        .map<List<double>>((row) => List<double>.from(row.map((v) => (v as num).toDouble())))
        .toList();
    _intercepts = List<double>.from(
      (data['intercepts'] as List).map((v) => (v as num).toDouble()),
    );

    _loaded = true;
  }

  /// symptoms: confirmed PRESENT (feature value 1)
  /// deniedSymptoms: confirmed ABSENT (feature value -1)
  /// Everything else is "unknown" (feature value 0).
  /// Matches prediction_service.py's feature_value() exactly, including
  /// the choice to use -1 (not just omitting) for denied symptoms, so a
  /// "No" answer actively counts as evidence, not just non-evidence.
  Map<String, dynamic> predict(List<String> symptoms, {List<String> deniedSymptoms = const []}) {
    _assertLoaded();

    final cols = _symptomColumns!;
    final vector = List<double>.generate(cols.length, (i) {
      final col = cols[i];
      if (deniedSymptoms.contains(col)) return -1.0;
      if (symptoms.contains(col)) return 1.0;
      return 0.0;
    });

    final scores = List<double>.generate(_classes!.length, (c) {
      double dot = _intercepts![c];
      final rowCoefs = _coefficients![c];
      for (var i = 0; i < vector.length; i++) {
        dot += rowCoefs[i] * vector[i];
      }
      return dot;
    });

    final probabilities = _softmax(scores);

    final ranked = List<int>.generate(_classes!.length, (i) => i)
      ..sort((a, b) => probabilities[b].compareTo(probabilities[a]));

    final allPredictions = ranked
        .map((i) => {
              'disease': _classes![i],
              'confidence': double.parse(probabilities[i].toStringAsFixed(4)),
            })
        .toList();

    return {
      'top_prediction': allPredictions[0],
      'all_predictions': allPredictions,
    };
  }

  /// Given the top-k candidate diseases, return the symptoms whose
  /// coefficients differ most between them - i.e. the most USEFUL
  /// follow-up questions to ask. Excludes symptoms already known.
  /// Mirrors get_distinguishing_symptoms() in prediction_service.py.
  List<String> getDistinguishingSymptoms(
    List<String> topCandidates,
    List<String> alreadyKnown, {
    int n = 3,
  }) {
    _assertLoaded();

    final indices = topCandidates
        .map((c) => _classes!.indexOf(c))
        .where((i) => i != -1)
        .toList();
    if (indices.length < 2) return [];

    final cols = _symptomColumns!;
    final variance = List<double>.generate(cols.length, (symptomIdx) {
      final values = indices.map((classIdx) => _coefficients![classIdx][symptomIdx]).toList();
      return _variance(values);
    });

    for (var i = 0; i < cols.length; i++) {
      if (alreadyKnown.contains(cols[i])) variance[i] = -1;
    }

    return _topNIndices(variance, n).map((i) => cols[i]).toList();
  }

  /// For the minimum-evidence gate: globally most discriminative symptoms
  /// across ALL diseases, when there aren't yet enough symptoms to narrow
  /// down top candidates meaningfully.
  /// Mirrors get_informative_symptoms() in prediction_service.py.
  List<String> getInformativeSymptoms(List<String> alreadyKnown, {int n = 3}) {
    _assertLoaded();

    final cols = _symptomColumns!;
    final variance = List<double>.generate(cols.length, (symptomIdx) {
      final values = _coefficients!.map((row) => row[symptomIdx]).toList();
      return _variance(values);
    });

    for (var i = 0; i < cols.length; i++) {
      if (alreadyKnown.contains(cols[i])) variance[i] = -1;
    }

    return _topNIndices(variance, n).map((i) => cols[i]).toList();
  }

  List<double> _softmax(List<double> scores) {
    final maxScore = scores.reduce(math.max); // numerical stability, same effect as sklearn's internal approach
    final exps = scores.map((s) => math.exp(s - maxScore)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  double _variance(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  List<int> _topNIndices(List<double> values, int n) {
    final indices = List<int>.generate(values.length, (i) => i)
      ..sort((a, b) => values[b].compareTo(values[a]));
    return indices.where((i) => values[i] >= 0).take(n).toList();
  }

  void _assertLoaded() {
    if (!_loaded) {
      throw StateError('DiseasePredictorService.loadModel() must be awaited before use.');
    }
  }
}
