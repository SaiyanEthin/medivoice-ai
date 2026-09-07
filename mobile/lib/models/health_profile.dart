/// A user's personal health profile, held on the device only.
///
/// Every field except the name is optional: the profile is meant to be
/// useful when partially filled, not a gate to using the app.
class HealthProfile {
  final String name;
  final int? age;
  final String? sex;
  final List<String> conditions;
  final List<String> allergies;

  const HealthProfile({
    required this.name,
    this.age,
    this.sex,
    this.conditions = const [],
    this.allergies = const [],
  });

  bool get isEmpty =>
      name.trim().isEmpty &&
      age == null &&
      sex == null &&
      conditions.isEmpty &&
      allergies.isEmpty;

  /// First name only, for greetings - "Hello, Ethin" reads better than
  /// the full name.
  String get greetingName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  HealthProfile copyWith({
    String? name,
    int? age,
    String? sex,
    List<String>? conditions,
    List<String>? allergies,
  }) {
    return HealthProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      conditions: conditions ?? this.conditions,
      allergies: allergies ?? this.allergies,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'sex': sex,
        'conditions': conditions,
        'allergies': allergies,
      };

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      name: (json['name'] ?? '') as String,
      age: json['age'] as int?,
      sex: json['sex'] as String?,
      conditions: List<String>.from(json['conditions'] ?? const []),
      allergies: List<String>.from(json['allergies'] ?? const []),
    );
  }
}
