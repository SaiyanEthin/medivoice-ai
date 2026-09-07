/// How strongly the user says they are experiencing a symptom.
///
/// Recorded as consultation metadata only. It is NOT fed to the
/// classifier: the training data is binary present/absent with no
/// validated severity labels, so any numeric weighting would be an
/// assumption rather than something the model learned.
enum SymptomSeverity { mild, moderate, severe }

extension SymptomSeverityLabel on SymptomSeverity {
  String get label {
    switch (this) {
      case SymptomSeverity.mild:
        return 'Mild';
      case SymptomSeverity.moderate:
        return 'Moderate';
      case SymptomSeverity.severe:
        return 'Severe';
    }
  }

  String get storageKey => name;
}

SymptomSeverity? severityFromKey(String? key) {
  if (key == null) return null;
  for (final value in SymptomSeverity.values) {
    if (value.storageKey == key) return value;
  }
  return null;
}
