import 'package:shared_preferences/shared_preferences.dart';
import '../models/vital_reading.dart';

enum TemperatureUnit { celsius, fahrenheit }

enum WeightUnit { kg, lb }

/// The unit a user prefers to read and enter measurements in.
///
/// Readings are STORED canonically - °F for temperature, kg for weight -
/// and converted only for entry and display. Storing in the display unit
/// would mean rewriting every past reading whenever the preference
/// changed, which is a good way to corrupt a health record.
///
/// A singleton loaded once at startup so widgets can read it
/// synchronously, matching how SymptomMatcherService is used.
class UnitPrefs {
  static final UnitPrefs _instance = UnitPrefs._internal();
  factory UnitPrefs() => _instance;
  UnitPrefs._internal();

  static const _tempKey = 'unit_temperature';
  static const _weightKey = 'unit_weight';

  /// Defaults match how readings were recorded before this existed, so
  /// nothing already stored changes meaning.
  TemperatureUnit temperature = TemperatureUnit.fahrenheit;
  WeightUnit weight = WeightUnit.kg;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final temp = prefs.getString(_tempKey);
      if (temp == TemperatureUnit.celsius.name) {
        temperature = TemperatureUnit.celsius;
      }
      final w = prefs.getString(_weightKey);
      if (w == WeightUnit.lb.name) weight = WeightUnit.lb;
    } catch (_) {
      // Fall back to the defaults rather than blocking app start.
    }
  }

  Future<void> setTemperature(TemperatureUnit unit) async {
    temperature = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tempKey, unit.name);
  }

  Future<void> setWeight(WeightUnit unit) async {
    weight = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightKey, unit.name);
  }
}

// --- conversions -----------------------------------------------------------

double celsiusToFahrenheit(double c) => c * 9 / 5 + 32;

double fahrenheitToCelsius(double f) => (f - 32) * 5 / 9;

const _lbPerKg = 2.20462262;

double kgToLb(double kg) => kg * _lbPerKg;

double lbToKg(double lb) => lb / _lbPerKg;

/// The unit label to show for [type], honouring the user's preference.
String displayUnitFor(VitalType type) {
  switch (type) {
    case VitalType.temperature:
      return UnitPrefs().temperature == TemperatureUnit.celsius
          ? '\u00B0C'
          : '\u00B0F';
    case VitalType.weight:
      return UnitPrefs().weight == WeightUnit.lb ? 'lb' : 'kg';
    default:
      return type.unit;
  }
}

/// Stored value -> the number to show the user.
double toDisplayValue(VitalType type, double canonical) {
  switch (type) {
    case VitalType.temperature:
      return UnitPrefs().temperature == TemperatureUnit.celsius
          ? fahrenheitToCelsius(canonical)
          : canonical;
    case VitalType.weight:
      return UnitPrefs().weight == WeightUnit.lb
          ? kgToLb(canonical)
          : canonical;
    default:
      return canonical;
  }
}

/// What the user typed -> the value to store.
double toCanonicalValue(VitalType type, double display) {
  switch (type) {
    case VitalType.temperature:
      return UnitPrefs().temperature == TemperatureUnit.celsius
          ? celsiusToFahrenheit(display)
          : display;
    case VitalType.weight:
      return UnitPrefs().weight == WeightUnit.lb ? lbToKg(display) : display;
    default:
      return display;
  }
}

/// The plausibility bounds expressed in the user's unit, so the error
/// message quotes numbers they recognise.
(double, double) displayPlausibleRange(VitalType type) {
  final range = type.plausibleRange;
  return (
    toDisplayValue(type, range.$1),
    toDisplayValue(type, range.$2),
  );
}

/// A reading rendered in the user's unit. Blood pressure keeps its
/// systolic/diastolic form; nothing else has a second value.
String formatReading(VitalReading reading) {
  final type = reading.type;
  final primary =
      toDisplayValue(type, reading.value).toStringAsFixed(type.decimals);
  if (type.hasSecondary && reading.secondaryValue != null) {
    return '$primary/${reading.secondaryValue!.toStringAsFixed(0)}';
  }
  return primary;
}
