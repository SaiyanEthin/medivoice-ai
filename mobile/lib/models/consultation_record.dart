import 'symptom_severity.dart';

/// One completed consultation, stored on the device.
///
/// Symptoms are kept as model COLUMN names rather than display labels, so
/// a record stays accurate if the wording of a label changes later. The
/// history screen resolves them for display.
class ConsultationRecord {
  final String id;
  final DateTime timestamp;
  final List<String> symptoms;
  final List<String> deniedSymptoms;

  /// Null when the assessment was uncertain - no condition was named, and
  /// storing one anyway would misrepresent what the user was shown.
  final String? disease;
  final double? confidence;

  final bool isUncertain;
  final String? uncertaintyReason;
  final int followupRounds;

  /// Symptom column -> reported severity, for symptoms the user confirmed
  /// and chose to grade. Optional, so this is usually a partial map.
  final Map<String, SymptomSeverity> severities;

  const ConsultationRecord({
    required this.id,
    required this.timestamp,
    required this.symptoms,
    this.deniedSymptoms = const [],
    this.disease,
    this.confidence,
    this.isUncertain = false,
    this.uncertaintyReason,
    this.followupRounds = 0,
    this.severities = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'symptoms': symptoms,
        'deniedSymptoms': deniedSymptoms,
        'disease': disease,
        'confidence': confidence,
        'isUncertain': isUncertain,
        'uncertaintyReason': uncertaintyReason,
        'followupRounds': followupRounds,
        'severities': severities
            .map((symptom, severity) => MapEntry(symptom, severity.storageKey)),
      };

  static Map<String, SymptomSeverity> _severitiesFrom(dynamic raw) {
    if (raw is! Map) return const {};
    final result = <String, SymptomSeverity>{};
    raw.forEach((key, value) {
      final severity = severityFromKey(value as String?);
      if (severity != null) result[key as String] = severity;
    });
    return result;
  }

  factory ConsultationRecord.fromJson(Map<String, dynamic> json) {
    return ConsultationRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      symptoms: List<String>.from(json['symptoms'] ?? const []),
      deniedSymptoms: List<String>.from(json['deniedSymptoms'] ?? const []),
      disease: json['disease'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      isUncertain: json['isUncertain'] as bool? ?? false,
      uncertaintyReason: json['uncertaintyReason'] as String?,
      followupRounds: json['followupRounds'] as int? ?? 0,
      severities: _severitiesFrom(json['severities']),
    );
  }
}
