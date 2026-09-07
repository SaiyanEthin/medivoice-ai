import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/core/unit_prefs.dart';
import 'package:medivoice_ai/models/vital_reading.dart';
import 'package:shared_preferences/shared_preferences.dart';

VitalReading _reading(VitalType type, double value, {double? secondary}) =>
    VitalReading(
      id: 'x',
      type: type,
      timestamp: DateTime(2026, 9, 7),
      value: value,
      secondaryValue: secondary,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // The singleton persists between tests, so reset it explicitly.
    UnitPrefs().temperature = TemperatureUnit.fahrenheit;
    UnitPrefs().weight = WeightUnit.kg;
  });

  group('conversion arithmetic', () {
    test('freezing and boiling points', () {
      expect(celsiusToFahrenheit(0), closeTo(32, 0.001));
      expect(celsiusToFahrenheit(100), closeTo(212, 0.001));
      expect(fahrenheitToCelsius(32), closeTo(0, 0.001));
      expect(fahrenheitToCelsius(212), closeTo(100, 0.001));
    });

    test('normal body temperature', () {
      expect(fahrenheitToCelsius(98.6), closeTo(37, 0.05));
      expect(celsiusToFahrenheit(37), closeTo(98.6, 0.05));
    });

    test('temperature conversion round trips', () {
      expect(fahrenheitToCelsius(celsiusToFahrenheit(36.8)),
          closeTo(36.8, 0.0001));
    });

    test('weight conversion round trips', () {
      expect(lbToKg(kgToLb(70)), closeTo(70, 0.0001));
    });

    test('a known weight conversion', () {
      expect(kgToLb(70), closeTo(154.32, 0.01));
    });
  });

  group('display in the chosen unit', () {
    test('fahrenheit shows the stored value unchanged', () {
      expect(displayUnitFor(VitalType.temperature), '\u00B0F');
      expect(toDisplayValue(VitalType.temperature, 98.6), closeTo(98.6, 0.001));
    });

    test('celsius converts for display', () {
      UnitPrefs().temperature = TemperatureUnit.celsius;
      expect(displayUnitFor(VitalType.temperature), '\u00B0C');
      expect(toDisplayValue(VitalType.temperature, 98.6), closeTo(37, 0.05));
    });

    test('pounds convert for display', () {
      UnitPrefs().weight = WeightUnit.lb;
      expect(displayUnitFor(VitalType.weight), 'lb');
      expect(toDisplayValue(VitalType.weight, 70), closeTo(154.32, 0.01));
    });

    test('other vitals are never converted', () {
      UnitPrefs().temperature = TemperatureUnit.celsius;
      UnitPrefs().weight = WeightUnit.lb;
      for (final type in [
        VitalType.bloodPressure,
        VitalType.bloodGlucose,
        VitalType.pulse,
        VitalType.oxygenSaturation,
      ]) {
        expect(toDisplayValue(type, 100), 100);
        expect(displayUnitFor(type), type.unit);
      }
    });
  });

  group('entry converts back to storage', () {
    test('celsius input is stored as fahrenheit', () {
      UnitPrefs().temperature = TemperatureUnit.celsius;
      expect(toCanonicalValue(VitalType.temperature, 37),
          closeTo(98.6, 0.05));
    });

    test('pound input is stored as kilograms', () {
      UnitPrefs().weight = WeightUnit.lb;
      expect(toCanonicalValue(VitalType.weight, 154.32), closeTo(70, 0.01));
    });

    test('entry and display are exact inverses', () {
      UnitPrefs().temperature = TemperatureUnit.celsius;
      final stored = toCanonicalValue(VitalType.temperature, 36.8);
      expect(toDisplayValue(VitalType.temperature, stored),
          closeTo(36.8, 0.0001));
    });
  });

  group('plausibility bounds follow the unit', () {
    test('fahrenheit bounds are the stored bounds', () {
      final range = displayPlausibleRange(VitalType.temperature);
      expect(range.$1, closeTo(90, 0.01));
      expect(range.$2, closeTo(115, 0.01));
    });

    test('celsius bounds accept a normal temperature', () {
      UnitPrefs().temperature = TemperatureUnit.celsius;
      final range = displayPlausibleRange(VitalType.temperature);
      // 36.8 was rejected outright before this existed.
      expect(36.8, greaterThan(range.$1));
      expect(36.8, lessThan(range.$2));
    });

    test('celsius bounds still reject nonsense', () {
      UnitPrefs().temperature = TemperatureUnit.celsius;
      final range = displayPlausibleRange(VitalType.temperature);
      expect(500, greaterThan(range.$2));
    });
  });

  group('formatReading', () {
    test('blood pressure keeps its two numbers', () {
      final reading =
          _reading(VitalType.bloodPressure, 124, secondary: 82);
      expect(formatReading(reading), '124/82');
    });

    test('temperature follows the preference', () {
      final reading = _reading(VitalType.temperature, 98.6);
      expect(formatReading(reading), '98.6');
      UnitPrefs().temperature = TemperatureUnit.celsius;
      expect(formatReading(reading), '37.0');
    });

    test('weight follows the preference', () {
      final reading = _reading(VitalType.weight, 70);
      expect(formatReading(reading), '70.0');
      UnitPrefs().weight = WeightUnit.lb;
      expect(formatReading(reading), '154.3');
    });
  });

  group('persistence', () {
    test('defaults match how readings were recorded before', () async {
      final prefs = UnitPrefs();
      await prefs.load();
      expect(prefs.temperature, TemperatureUnit.fahrenheit);
      expect(prefs.weight, WeightUnit.kg);
    });

    test('a chosen unit survives a reload', () async {
      final prefs = UnitPrefs();
      await prefs.setTemperature(TemperatureUnit.celsius);
      await prefs.setWeight(WeightUnit.lb);

      prefs.temperature = TemperatureUnit.fahrenheit;
      prefs.weight = WeightUnit.kg;
      await prefs.load();

      expect(prefs.temperature, TemperatureUnit.celsius);
      expect(prefs.weight, WeightUnit.lb);
    });
  });
}
