import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vital_reading.dart';

/// Local storage for vital readings.
///
/// All types share one stored list. Keeping six separate keys would mean
/// six reads to build a dashboard, and the trends screen would have to
/// stitch them together anyway.
///
/// Capped PER TYPE rather than overall, so a daily weight log can't push
/// out every blood pressure reading.
class VitalsService {
  static const _key = 'vital_readings';
  static const maxPerType = 100;

  /// Every reading, newest first.
  Future<List<VitalReading>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      final readings = decoded
          .map((e) => VitalReading.fromJson(e as Map<String, dynamic>))
          .whereType<VitalReading>()
          .toList();
      readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return readings;
    } catch (_) {
      return [];
    }
  }

  Future<List<VitalReading>> loadByType(VitalType type) async {
    final all = await loadAll();
    return all.where((r) => r.type == type).toList();
  }

  Future<VitalReading?> latest(VitalType type) async {
    final readings = await loadByType(type);
    return readings.isEmpty ? null : readings.first;
  }

  /// The most recent reading of every type, for the vitals screen and the
  /// dashboard. Types with no readings map to null.
  Future<Map<VitalType, VitalReading?>> latestOfEach() async {
    final all = await loadAll();
    final result = <VitalType, VitalReading?>{};
    for (final type in VitalType.values) {
      final match = all.where((r) => r.type == type);
      result[type] = match.isEmpty ? null : match.first;
    }
    return result;
  }

  Future<void> add(VitalReading reading) async {
    final all = await loadAll();
    all.insert(0, reading);

    final sameType = all.where((r) => r.type == reading.type).toList();
    if (sameType.length > maxPerType) {
      final keep = sameType.take(maxPerType).map((r) => r.id).toSet();
      all.removeWhere((r) => r.type == reading.type && !keep.contains(r.id));
    }

    await _write(all);
  }

  Future<void> delete(String id) async {
    final all = await loadAll()
      ..removeWhere((r) => r.id == id);
    await _write(all);
  }

  Future<void> clearType(VitalType type) async {
    final all = await loadAll()
      ..removeWhere((r) => r.type == type);
    await _write(all);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<int> countAll() async => (await loadAll()).length;

  Future<void> _write(List<VitalReading> readings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(readings.map((r) => r.toJson()).toList()));
  }
}
