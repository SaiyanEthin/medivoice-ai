class Advice {
  final String disease;
  final String severity;
  final List<String> advice;

  Advice({
    required this.disease,
    required this.severity,
    required this.advice,
  });

  factory Advice.fromJson(Map<String, dynamic> json) {
    return Advice(
      disease: json['disease'] as String,
      severity: json['severity'] as String,
      advice: (json['advice'] as List).map((e) => e.toString()).toList(),
    );
  }

  /// Severity strings from the backend are free text like
  /// "serious - needs prompt medical attention". This buckets them
  /// so the UI can pick a colour/icon without string-matching everywhere.
  SeverityLevel get level {
    final s = severity.toLowerCase();
    if (s.startsWith('serious')) return SeverityLevel.serious;
    if (s.startsWith('chronic')) return SeverityLevel.chronic;
    if (s.startsWith('moderate')) return SeverityLevel.moderate;
    return SeverityLevel.mild;
  }
}

enum SeverityLevel { mild, moderate, chronic, serious }