import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/services/disease_predictor_service.dart';

/// 25-class model verification.
///
/// The 10-class model keeps its own regression test
/// (disease_predictor_service_test.dart) and stays the production default
/// until these results are reviewed.
///
/// Assertions use SIGNATURE symptoms identified in the dataset
/// investigation - symptoms present in 100% of that disease's rows and 0%
/// of every other disease's. If the port is correct, these must win.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DiseasePredictorService predictor;

  setUpAll(() async {
    predictor = DiseasePredictorService(
      assetPath: DiseasePredictorService.twentyFiveClassModelAsset,
    );
    await predictor.loadModel();
  });

  String top(List<String> symptoms) {
    final r = predictor.predict(symptoms);
    final t = r['top_prediction'] as Map;
    final all = (r['all_predictions'] as List).take(3).map((p) {
      final m = p as Map;
      return '${m['disease']} ${((m['confidence'] as double) * 100).toStringAsFixed(1)}%';
    }).join(', ');
    print('  $symptoms -> $all');
    return t['disease'] as String;
  }

  group('model loading', () {
    test('loads 25 classes and 102 symptom columns', () {
      expect(predictor.classes.length, 25);
      expect(predictor.symptomColumns.length, 102);
    });

    test('probabilities sum to 1', () {
      final r = predictor.predict(['high_fever', 'cough']);
      final total = (r['all_predictions'] as List)
          .fold<double>(0, (s, p) => s + ((p as Map)['confidence'] as double));
      expect(total, closeTo(1.0, 0.01));
    });

    test('the 10-class model still loads independently', () async {
      final old = DiseasePredictorService(
        assetPath: DiseasePredictorService.tenClassModelAsset,
      );
      await old.loadModel();
      expect(old.classes.length, 10);
      expect(old.symptomColumns.length, 57);
    });
  });

  group('signature-symptom predictions', () {
    test('Dengue (pain_behind_the_eyes is a 100% signature)', () {
      expect(
          top([
            'pain_behind_the_eyes', 'high_fever', 'joint_pain', 'chills',
            'headache', 'nausea', 'loss_of_appetite', 'back_pain',
            'muscle_pain', 'red_spots_over_body',
          ]),
          'Dengue');
    });

    test('Diabetes (polyuria + increased_appetite are 100% signatures)', () {
      expect(top(['polyuria', 'increased_appetite', 'irregular_sugar_level']),
          'Diabetes');
    });

    test('Hypothyroidism (enlarged_thyroid + brittle_nails are 100% signatures)', () {
      expect(top(['enlarged_thyroid', 'brittle_nails', 'weight_gain']),
          'Hypothyroidism');
    });

    test('Tuberculosis (blood_in_sputum is a 100% signature)', () {
      expect(
          top([
            'blood_in_sputum', 'yellowing_of_eyes', 'mild_fever', 'cough',
            'chest_pain', 'breathlessness', 'weight_loss', 'fatigue',
            'sweating', 'loss_of_appetite', 'phlegm',
          ]),
          'Tuberculosis');
    });

    test('Hypoglycemia (slurred_speech + palpitations are 100% signatures)', () {
      expect(top(['slurred_speech', 'palpitations', 'anxiety']), 'Hypoglycemia');
    });

    test('Common Cold (runny_nose + congestion are 100% signatures)', () {
      expect(
          top([
            'runny_nose', 'congestion', 'continuous_sneezing',
            'throat_irritation', 'redness_of_eyes', 'sinus_pressure',
            'loss_of_smell', 'chills', 'headache', 'cough', 'high_fever',
          ]),
          'Common Cold');
    });
  });

  group('sparse input is deliberately unconfident', () {
    // Diseases with large symptom profiles (Dengue 13, TB 16, Common Cold 17
    // symptoms per row) cannot be identified from 2-3 symptoms across 25
    // classes. The model returns a flat distribution instead of a confident
    // guess, and the orchestrator's confidence gate turns that into
    // follow-up questions. This is intended behaviour, not a defect - the
    // 10-class model named "Bronchial Asthma" at 72.9% from three generic
    // symptoms, which was confidently wrong.
    test('three generic symptoms produce low confidence, not a firm answer', () {
      final r = predictor.predict(['high_fever', 'cough', 'fatigue']);
      final conf = (r['top_prediction'] as Map)['confidence'] as double;
      print('  [high_fever, cough, fatigue] -> '
          '${(r['top_prediction'] as Map)['disease']} '
          '${(conf * 100).toStringAsFixed(1)}%');
      expect(conf, lessThan(0.65),
          reason: 'should fall below the confidence gate and trigger follow-ups');
    });

    test('the same symptoms plus follow-up answers sharpen the result', () {
      final sparse = predictor.predict(['high_fever', 'cough']);
      final richer = predictor.predict([
        'high_fever', 'cough', 'chills', 'headache', 'sweating',
        'nausea', 'muscle_pain', 'vomiting',
      ]);
      final sparseConf = (sparse['top_prediction'] as Map)['confidence'] as double;
      final richerConf = (richer['top_prediction'] as Map)['confidence'] as double;
      print('  2 symptoms -> ${(sparseConf * 100).toStringAsFixed(1)}%, '
          '8 symptoms -> ${(richerConf * 100).toStringAsFixed(1)}%');
      expect(richerConf, greaterThan(sparseConf));
    });
  });

  group('newly added diseases are reachable', () {
    test('Psoriasis', () {
      expect(top(['skin_peeling', 'silver_like_dusting', 'small_dents_in_nails']),
          'Psoriasis');
    });

    test('Impetigo', () {
      expect(top(['blister', 'red_sore_around_nose', 'yellow_crust_ooze']),
          'Impetigo');
    });

    test('Urinary tract infection', () {
      expect(top(['burning_micturition', 'bladder_discomfort',
          'foul_smell_of urine', 'continuous_feel_of_urine']),
          'Urinary tract infection');
    });

    test('Arthritis', () {
      expect(top(['swelling_joints', 'movement_stiffness', 'painful_walking']),
          'Arthritis');
    });

    test('Vertigo', () {
      expect(top(['spinning_movements', 'unsteadiness', 'loss_of_balance']),
          '(vertigo) Paroymsal  Positional Vertigo');
    });
  });

  group('the original 10 diseases still behave sensibly', () {
    test('Migraine', () {
      expect(top(['visual_disturbances', 'headache', 'indigestion',
          'irritability']), 'Migraine');
    });

    test('Jaundice', () {
      expect(top(['yellowish_skin', 'dark_urine', 'itching',
          'loss_of_appetite']), 'Jaundice');
    });

    test('Typhoid', () {
      expect(top(['toxic_look_(typhos)', 'belly_pain', 'constipation',
          'high_fever']), 'Typhoid');
    });
  });
}
