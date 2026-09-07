import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/core/text_scale_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TextScalePrefs().value = TextSizeOption.normal;
  });

  group('options', () {
    test('every option has a label and a scale', () {
      for (final option in TextSizeOption.values) {
        expect(option.label, isNotEmpty);
        expect(option.scale, greaterThan(0));
      }
    });

    test('normal is exactly unscaled', () {
      expect(TextSizeOption.normal.scale, 1.0);
    });

    test('scales increase across the options', () {
      final scales = TextSizeOption.values.map((o) => o.scale).toList();
      for (var i = 1; i < scales.length; i++) {
        expect(scales[i], greaterThan(scales[i - 1]));
      }
    });

    test('the largest stays within what the layouts survive', () {
      // Above roughly 1.4 the vitals grid and follow-up buttons wrap
      // badly; raising this needs those layouts reworked first.
      expect(TextSizeOption.largest.scale, lessThanOrEqualTo(1.4));
    });
  });

  group('persistence', () {
    test('defaults to normal', () async {
      final prefs = TextScalePrefs();
      await prefs.load();
      expect(prefs.value, TextSizeOption.normal);
    });

    test('a choice survives a reload', () async {
      final prefs = TextScalePrefs();
      await prefs.set(TextSizeOption.larger);

      prefs.value = TextSizeOption.normal;
      await prefs.load();

      expect(prefs.value, TextSizeOption.larger);
    });

    test('an unrecognised stored value falls back to normal', () async {
      SharedPreferences.setMockInitialValues({'text_size': 'enormous'});
      final prefs = TextScalePrefs();
      await prefs.load();
      expect(prefs.value, TextSizeOption.normal);
    });
  });

  test('setting the size notifies listeners so the app rescales', () async {
    final prefs = TextScalePrefs();
    var notified = 0;
    void listener() => notified++;
    prefs.addListener(listener);

    await prefs.set(TextSizeOption.large);

    expect(notified, greaterThan(0));
    prefs.removeListener(listener);
  });
}
