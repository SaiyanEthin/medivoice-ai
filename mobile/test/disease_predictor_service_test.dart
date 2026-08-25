import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/services/disease_predictor_service.dart';

/// Verifies the on-device Dart port produces the SAME predictions as the
/// Python backend for known inputs, before we trust it enough to retire
/// the HTTP call entirely.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('matches Python backend for [high_fever, cough, fatigue]', () async {
    final predictor = DiseasePredictorService();
    await predictor.loadModel();

    final result = predictor.predict(['high_fever', 'cough', 'fatigue']);
    final top = result['top_prediction'] as Map;

    print('Dart top prediction: $top');
    print('Dart all predictions: ${result['all_predictions']}');

    // Ground truth captured directly from the live Python backend for this
    // exact input on 2026-08-25:
    // {"disease":"Bronchial Asthma","confidence":0.7292}
    expect(top['disease'], 'Bronchial Asthma');
    expect((top['confidence'] as double) - 0.7292, closeTo(0, 0.001));
  });
}
