import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/services/symptom_matcher_service.dart';

/// Milestone A verification.
///
/// SymptomMatcherService is a singleton, so initialize() once and reuse -
/// calling it again is a no-op by design.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final matcher = SymptomMatcherService();

  setUpAll(() async {
    await matcher.initialize();
  });

  group('match:false entries', () {
    test('family_history is NOT matchable from free text', () {
      final result = matcher.analyze('asthma runs in my family');
      expect(result.present, isNot(contains('family_history')));
    });

    test('toxic_look_(typhos) is NOT matchable from free text', () {
      final result = matcher.analyze('looking very unwell');
      expect(result.present, isNot(contains('toxic_look_(typhos)')));
    });

    test('internal_itching is NOT matchable from free text', () {
      final result = matcher.analyze('itching inside the stomach');
      expect(result.present, isNot(contains('internal_itching')));
    });

    test('but they STILL produce readable labels for follow-up questions', () {
      expect(matcher.getReadableLabel('family_history'), 'a family history of asthma');
      expect(matcher.getReadableLabel('toxic_look_(typhos)'), 'a very unwell appearance');
      expect(matcher.getReadableLabel('internal_itching'), 'internal itching');
    });
  });

  group('label field', () {
    test('label is preferred over the first English phrase', () {
      // en[0] is "feeling low" - would read as "Do you have feeling low?"
      expect(matcher.getReadableLabel('depression'), 'low mood');
      // en[0] is "room is spinning"
      expect(matcher.getReadableLabel('spinning_movements'), 'a spinning sensation');
      // en[0] is "coughing up blood"
      expect(matcher.getReadableLabel('blood_in_sputum'), 'blood when coughing');
    });

    test('unknown columns still fall back to a readable form', () {
      expect(matcher.getReadableLabel('some_unknown_column'), 'some unknown column');
    });
  });

  group('shared phrases map to multiple columns (decision #8)', () {
    test('"stomach pain" credits both belly_pain and stomach_pain', () {
      final result = matcher.analyze('I have stomach pain');
      expect(result.present, contains('belly_pain'));
      expect(result.present, contains('stomach_pain'));
    });

    test('"losing balance" credits both loss_of_balance and unsteadiness', () {
      final result = matcher.analyze('I keep losing balance');
      expect(result.present, contains('loss_of_balance'));
      expect(result.present, contains('unsteadiness'));
    });

    test('"heart racing" credits both fast_heart_rate and palpitations', () {
      final result = matcher.analyze('my heart racing a lot');
      expect(result.present, contains('fast_heart_rate'));
      expect(result.present, contains('palpitations'));
    });
  });

  group('newly added phrases match', () {
    test('Dengue signature symptom', () {
      expect(matcher.analyze('pain behind my eyes').present,
          contains('pain_behind_the_eyes'));
    });

    test('Tuberculosis primary voice feature', () {
      expect(matcher.analyze('I am coughing up blood').present,
          contains('blood_in_sputum'));
    });

    test('Hypothyroidism distinguisher', () {
      expect(matcher.analyze('my nails break easily').present,
          contains('brittle_nails'));
    });

    test('Vertigo distinguisher', () {
      expect(matcher.analyze('the room is spinning').present,
          contains('spinning_movements'));
    });
  });

  group('excluded from voice matching by decision', () {
    test('mild_fever was never added to the dictionary', () {
      // Falls back to the raw-column-name form, proving no entry exists
      expect(matcher.getReadableLabel('mild_fever'), 'mild fever');
    });

    test('abnormal_menstruation was never added to the dictionary', () {
      expect(matcher.getReadableLabel('abnormal_menstruation'), 'abnormal menstruation');
    });
  });

  group('substring false-positive fixes', () {
    test('"gale mein kharash" gives throat_irritation, NOT skin_rash', () {
      final r = matcher.analyze('gale mein kharash');
      expect(r.present, contains('throat_irritation'));
      expect(r.present, isNot(contains('skin_rash')),
          reason: '"rash" must not fire as a substring of "kharash"');
    });

    test('"feeling like vomiting" gives nausea, NOT vomiting', () {
      final r = matcher.analyze('feeling like vomiting');
      expect(r.present, contains('nausea'));
      expect(r.present, isNot(contains('vomiting')),
          reason: 'feeling like vomiting is nausea, not actual vomiting');
    });

    test('a genuine rash still matches skin_rash', () {
      final r = matcher.analyze('I have a rash on my skin');
      expect(r.present, contains('skin_rash'));
    });

    test('genuine vomiting still matches vomiting', () {
      final r = matcher.analyze('I have been vomiting since morning');
      expect(r.present, contains('vomiting'));
    });

    test('suppression is scoped to the clause containing the phrase', () {
      // Clause splitter breaks on commas, so the rash is in its own clause
      // and must still register.
      final r = matcher.analyze('gale mein kharash, and a rash on my arm');
      expect(r.present, contains('throat_irritation'));
      expect(r.present, contains('skin_rash'));
    });

    test('unrelated multi-symptom matching is unchanged', () {
      final r = matcher.analyze('I have fever and cough');
      expect(r.present, contains('cough'));
      expect(r.present.length, greaterThanOrEqualTo(2));
    });

    test('"coughing up blood" still credits cough as well', () {
      // Guards against a future switch to longest-phrase-wins, which would
      // silently drop cough here.
      final r = matcher.analyze('I am coughing up blood');
      expect(r.present, contains('blood_in_sputum'));
      expect(r.present, contains('cough'));
    });
  });

  group('negation still works on new phrases', () {
    test('"no neck pain" routes to denied, not present', () {
      final result = matcher.analyze('no neck pain');
      expect(result.denied, contains('neck_pain'));
      expect(result.present, isNot(contains('neck_pain')));
    });
  });
}
