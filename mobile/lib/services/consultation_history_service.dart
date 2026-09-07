import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consultation_record.dart';

/// Stores completed consultations on the device.
///
/// Capped: without a limit this list grows forever, and shared_preferences
/// rewrites the whole value on every save. Fifty is far more than anyone
/// will look back through and keeps writes cheap.
class ConsultationHistoryService {
  static const _key = 'consultation_history';
  static const maxRecords = 50;

  /// Newest first.
  Future<List<ConsultationRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      final records = decoded
          .map((e) => ConsultationRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return records;
    } catch (_) {
      // Corrupt or from an older shape - report empty rather than crashing
      // the history screen.
      return [];
    }
  }

  Future<void> add(ConsultationRecord record) async {
    final records = await load();
    records.insert(0, record);
    if (records.length > maxRecords) {
      records.removeRange(maxRecords, records.length);
    }
    await _write(records);
  }

  Future<void> delete(String id) async {
    final records = await load()
      ..removeWhere((r) => r.id == id);
    await _write(records);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<int> count() async => (await load()).length;

  Future<void> _write(List<ConsultationRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(records.map((r) => r.toJson()).toList()));
  }
}
