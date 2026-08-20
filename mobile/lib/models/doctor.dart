class Doctor {
  final String name;
  final String specialization;
  final String district;
  final String phone;
  final double distanceKm;

  Doctor({
    required this.name,
    required this.specialization,
    required this.district,
    required this.phone,
    required this.distanceKm,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      district: json['district'] as String,
      phone: json['phone'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
    );
  }

  /// Rough banding so the UI can show "nearby" vs "further away"
  /// without every screen re-deriving it from the raw number.
  bool get isNearby => distanceKm <= 10;
}