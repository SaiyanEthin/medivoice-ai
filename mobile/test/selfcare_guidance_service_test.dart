import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/services/selfcare_guidance_service.dart';

/// Milestone B: rule-based, offline self-care guidance.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = SelfCareGuidanceService();

  setUpAll(() async {
    await service.initialize();
  });

  group('symptom-group matching', () {
    test('fever symptoms produce fever/respiratory guidance', () {
      final g = service.guidanceFor(['high_fever', 'cough'])!;
      expect(g.guidance.any((t) => t.toLowerCase().contains('warm fluids')), isTrue);
    });

    test('GI symptoms produce hydration/small-meal guidance', () {
      final g = service.guidanceFor(['vomiting', 'diarrhoea'])!;
      expect(g.guidance.any((t) => t.toLowerCase().contains('small amounts')), isTrue);
      // Still present because gi_upset is ordered to keep this within the
      // per-group cap - it is the most safety-relevant line in that group.
      expect(g.guidance.any((t) => t.toLowerCase().contains('dehydration')), isTrue);
    });

    test('headache symptoms produce rest/screen guidance', () {
      final g = service.guidanceFor(['headache'])!;
      expect(g.guidance.any((t) => t.toLowerCase().contains('quiet')), isTrue);
    });

    test('skin symptoms produce skin-care guidance', () {
      final g = service.guidanceFor(['skin_rash', 'itching'])!;
      expect(g.guidance.any((t) => t.toLowerCase().contains('scratching')), isTrue);
    });

    test('multiple groups are combined', () {
      final g = service.guidanceFor(['high_fever', 'vomiting'])!;
      expect(g.guidance.any((t) => t.toLowerCase().contains('warm fluids')), isTrue);
      expect(g.guidance.any((t) => t.toLowerCase().contains('small amounts')), isTrue);
    });

    test('bullets are de-duplicated across overlapping groups', () {
      // malaise is in both fever_respiratory and aches_fatigue
      final g = service.guidanceFor(['malaise', 'high_fever', 'fatigue'])!;
      expect(g.guidance.length, g.guidance.toSet().length,
          reason: 'duplicate bullets should be removed');
    });
  });

  group('bullet caps', () {
    test('a single matched group yields at most 2 bullets', () {
      final g = service.guidanceFor(['high_fever'])!;
      expect(g.guidance.length, lessThanOrEqualTo(2));
    });

    test('a broad symptom set is capped at 8 bullets total', () {
      // The live screenshot case: Yes to nearly everything matched four
      // groups and produced ~13 bullets.
      final g = service.guidanceFor([
        'high_fever', 'cough', 'fatigue', 'muscle_pain', 'diarrhoea',
        'sweating', 'sunken_eyes', 'breathlessness', 'headache',
        'skin_rash', 'burning_micturition', 'throat_irritation',
      ])!;
      expect(g.guidance.length, lessThanOrEqualTo(8));
      expect(g.guidance.length, g.guidance.toSet().length,
          reason: 'no duplicate bullets');
    });

    test('every matched group is represented before any gets a second bullet', () {
      // fever/respiratory + GI: both must appear, neither may be crowded out.
      final g = service.guidanceFor(['high_fever', 'vomiting'])!;
      expect(g.guidance.any((t) => t.toLowerCase().contains('warm fluids')), isTrue);
      expect(g.guidance.any((t) => t.toLowerCase().contains('small amounts')), isTrue);
    });

    test('red flags are NOT capped - all safety lines always show', () {
      final g = service.guidanceFor(['high_fever'])!;
      expect(g.redFlags.length, greaterThanOrEqualTo(6));
    });
  });

  group('fallback behaviour', () {
    test('unmatched symptoms fall back to generic guidance', () {
      final g = service.guidanceFor(['family_history'])!;
      expect(g.guidance.any((t) => t.toLowerCase().contains('rest and drink')), isTrue);
    });

    test('empty symptom list still returns guidance', () {
      final g = service.guidanceFor([])!;
      expect(g.guidance, isNotEmpty);
    });
  });

  group('safety invariants', () {
    test('red flags are identical regardless of symptoms (no dynamic promotion)', () {
      final a = service.guidanceFor(['high_fever'])!.redFlags;
      final b = service.guidanceFor(['chest_pain', 'breathlessness'])!.redFlags;
      final c = service.guidanceFor([])!.redFlags;
      expect(a, equals(b));
      expect(a, equals(c));
    });

    test('red flags always include the core emergency signs', () {
      final f = service.guidanceFor(['itching'])!.redFlags.join(' ').toLowerCase();
      expect(f, contains('breathing'));
      expect(f, contains('chest pain'));
      expect(f, contains('fainting'));
    });

    test('disclaimer states this is not diagnosis or treatment', () {
      final d = service.guidanceFor(['headache'])!.disclaimer.toLowerCase();
      expect(d, contains('does not diagnose'));
    });

    test('no guidance text names a disease', () {
      final diseases = [
        'asthma', 'dengue', 'diabetes', 'malaria', 'typhoid', 'jaundice',
        'migraine', 'tuberculosis', 'psoriasis', 'impetigo', 'gerd',
        'hypertension', 'hypothyroid', 'arthritis', 'vertigo',
      ];
      final all = [
        ...service.guidanceFor(['high_fever', 'vomiting', 'headache',
            'skin_rash', 'burning_micturition', 'fatigue'])!.guidance,
        ...service.guidanceFor([])!.redFlags,
      ].join(' ').toLowerCase();
      for (final d in diseases) {
        expect(all.contains(d), isFalse, reason: 'guidance must not name "$d"');
      }
    });
  });
}
