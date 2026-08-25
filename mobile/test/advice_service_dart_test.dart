import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/services/advice_service_dart.dart';

/// Verifies the on-device advice lookup matches the Python backend exactly,
/// including the ┬░F special character in Common Cold's advice - a good
/// canary for any encoding issues introduced when the JSON was copied
/// into the Flutter assets folder.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('matches Python backend for Common Cold', () async {
    final service = AdviceService();
    await service.loadTemplates();

    final result = service.getAdvice('Common Cold');
    print('Dart advice result: $result');

    // Ground truth captured directly from the live Python backend on 2026-08-25:
    // {"disease":"Common Cold","severity":"mild","advice":["Drink warm fluids and rest well",
    // "Use steam inhalation to relieve congestion","Take paracetamol only if fever crosses 100°F",
    // "Visit a doctor if symptoms last more than 7 days"]}
    expect(result['disease'], 'Common Cold');
    expect(result['severity'], 'mild');
    expect(result['advice'], [
      'Drink warm fluids and rest well',
      'Use steam inhalation to relieve congestion',
      'Take paracetamol only if fever crosses 100°F',
      'Visit a doctor if symptoms last more than 7 days',
    ]);
  });

  test('falls back gracefully for an unknown disease', () async {
    final service = AdviceService();
    await service.loadTemplates();

    final result = service.getAdvice('Some Random Disease');
    expect(result['severity'], 'unknown');
    expect(result['advice'], ['No advice template found for this disease. Please consult a physician.']);
  });
}
