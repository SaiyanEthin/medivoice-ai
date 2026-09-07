/// The vitals this app records.
///
/// One enum plus one reading class rather than six separate models: the
/// dashboard and trends both need to treat these uniformly, and six
/// parallel storage paths would have to be unified later anyway.
enum VitalType {
  bloodPressure,
  bloodGlucose,
  pulse,
  oxygenSaturation,
  temperature,
  weight,
}

extension VitalTypeInfo on VitalType {
  String get label {
    switch (this) {
      case VitalType.bloodPressure:
        return 'Blood pressure';
      case VitalType.bloodGlucose:
        return 'Blood glucose';
      case VitalType.pulse:
        return 'Pulse rate';
      case VitalType.oxygenSaturation:
        return 'Oxygen saturation';
      case VitalType.temperature:
        return 'Temperature';
      case VitalType.weight:
        return 'Weight';
    }
  }

  String get unit {
    switch (this) {
      case VitalType.bloodPressure:
        return 'mmHg';
      case VitalType.bloodGlucose:
        return 'mg/dL';
      case VitalType.pulse:
        return 'BPM';
      case VitalType.oxygenSaturation:
        return '%';
      case VitalType.temperature:
        return '\u00B0F';
      case VitalType.weight:
        return 'kg';
    }
  }

  /// Blood pressure is the only one with two numbers.
  bool get hasSecondary => this == VitalType.bloodPressure;

  String get primaryFieldLabel =>
      this == VitalType.bloodPressure ? 'Systolic' : label;

  String get secondaryFieldLabel => 'Diastolic';

  /// How many decimals to show. Pulse and glucose are whole numbers in
  /// practice; temperature and weight are not.
  int get decimals {
    switch (this) {
      case VitalType.temperature:
      case VitalType.weight:
        return 1;
      default:
        return 0;
    }
  }

  /// PLAUSIBILITY bounds, not clinical ones. These exist to catch a
  /// mistyped digit, and are deliberately wide enough that a genuinely
  /// unwell person's reading still saves - the app must never refuse to
  /// record a real measurement because it looks alarming.
  (double, double) get plausibleRange {
    switch (this) {
      case VitalType.bloodPressure:
        return (50, 300);
      case VitalType.bloodGlucose:
        return (20, 800);
      case VitalType.pulse:
        return (20, 250);
      case VitalType.oxygenSaturation:
        return (50, 100);
      case VitalType.temperature:
        return (90, 115);
      case VitalType.weight:
        return (1, 400);
    }
  }

  (double, double) get secondaryPlausibleRange => (30, 200);

  String get storageKey => name;
}

/// A single dated measurement.
class VitalReading {
  final String id;
  final VitalType type;
  final DateTime timestamp;
  final double value;

  /// Diastolic, for blood pressure. Null for every other type.
  final double? secondaryValue;

  /// Free text - useful mainly for glucose, where a number without
  /// "before food" or "after food" is hard to interpret later.
  final String? note;

  const VitalReading({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.value,
    this.secondaryValue,
    this.note,
  });

  String get formatted {
    final primary = value.toStringAsFixed(type.decimals);
    if (type.hasSecondary && secondaryValue != null) {
      return '$primary/${secondaryValue!.toStringAsFixed(0)}';
    }
    return primary;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.storageKey,
        'timestamp': timestamp.toIso8601String(),
        'value': value,
        'secondaryValue': secondaryValue,
        'note': note,
      };

  static VitalReading? fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final type = VitalType.values.where((t) => t.storageKey == typeName);
    if (type.isEmpty) return null; // unknown type from a newer version
    return VitalReading(
      id: json['id'] as String,
      type: type.first,
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      secondaryValue: (json['secondaryValue'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );
  }
}
