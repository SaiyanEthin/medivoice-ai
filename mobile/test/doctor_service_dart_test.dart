import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/services/doctor_service_dart.dart';

/// Verifies the on-device doctor lookup matches the Python backend exactly:
/// same 5 doctors, same distance-ascending order.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('matches Python backend for Bronchial Asthma', () async {
    final service = DoctorService();
    await service.loadDoctors();

    final result = service.getDoctorsForDisease('Bronchial Asthma');
    print('Dart doctors result: $result');

    // Ground truth captured directly from the live Python backend on 2026-08-25:
    // Dr. Anitha Rao (3.2), Dr. Ravi Chandran (7.0), Dr. Suresh Kumar (8.5),
    // Dr. Kavya Reddy (42.0), Dr. Pooja Hegde (50.0)
    expect(result.length, 5);
    expect(result.map((d) => d['name']).toList(), [
      'Dr. Anitha Rao',
      'Dr. Ravi Chandran',
      'Dr. Suresh Kumar',
      'Dr. Kavya Reddy',
      'Dr. Pooja Hegde',
    ]);
    expect(result.map((d) => d['distance_km']).toList(), [3.2, 7.0, 8.5, 42.0, 50.0]);
  });

  test('falls back to General Physician for an unmapped disease', () async {
    final service = DoctorService();
    await service.loadDoctors();

    final result = service.getDoctorsForDisease('Some Random Disease');
    // Every doctor returned should be a General Physician, same as the
    // Python fallback ["General Physician"].
    expect(result.every((d) => d['specialization'] == 'General Physician'), true);
  });
}
