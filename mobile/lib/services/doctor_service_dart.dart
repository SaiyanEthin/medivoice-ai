import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// On-device port of backend/services/doctor_service.py.
/// The original table has 15 rows - too small to justify a real on-device
/// SQL engine (sqflite), so this loads the same data as flat JSON and
/// filters/sorts in Dart instead. Same disease->specialization mapping,
/// same "closest first" ordering, same result shape.
class DoctorService {
  List<Map<String, dynamic>>? _doctors;
  bool _loaded = false;

  /// Mirrors DISEASE_TO_SPECIALIZATION in doctor_service.py exactly.
  static const Map<String, List<String>> _diseaseToSpecialization = {
    "Common Cold": ["General Physician", "ENT Specialist"],
    "Gastroenteritis": ["General Physician", "Gastroenterologist"],
    "Diabetes": ["Endocrinologist", "General Physician"],
    "Hypertension": ["Cardiologist", "General Physician"],
    "Migraine": ["Neurologist", "General Physician"],
    "Malaria": ["General Physician", "Infectious Disease Specialist"],
    "Typhoid": ["General Physician", "Infectious Disease Specialist"],
    "Dengue": ["General Physician", "Infectious Disease Specialist"],
    "Bronchial Asthma": ["Pulmonologist", "General Physician"],
    "Jaundice": ["Hepatologist", "Gastroenterologist", "General Physician"],
  };

  Future<void> loadDoctors() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/doctors.json');
    final List<dynamic> decoded = jsonDecode(raw);
    _doctors = decoded.cast<Map<String, dynamic>>();
    _loaded = true;
  }

  /// Mirrors get_doctors_for_disease() exactly: filter by the disease's
  /// mapped specializations (defaulting to General Physician for an
  /// unmapped disease, same as the Python fallback), sort by distance
  /// ascending, take the closest [limit].
  List<Map<String, dynamic>> getDoctorsForDisease(String disease, {int limit = 5}) {
    if (!_loaded) {
      throw StateError('DoctorService.loadDoctors() must be awaited before use.');
    }

    final trimmed = disease.trim();
    final specializations = _diseaseToSpecialization[trimmed] ?? const ["General Physician"];

    final matches = _doctors!
        .where((doc) => specializations.contains(doc['specialization']))
        .toList()
      ..sort((a, b) => (a['distance_km'] as num).compareTo(b['distance_km'] as num));

    return matches.take(limit).toList();
  }
}
