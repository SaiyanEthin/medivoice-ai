import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/models/consultation_record.dart';
import 'package:medivoice_ai/services/consultation_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

ConsultationRecord _record({
  required String id,
  required DateTime at,
  String? disease = 'Bronchial Asthma',
  double? confidence = 0.77,
  bool uncertain = false,
}) {
  return ConsultationRecord(
    id: id,
    timestamp: at,
    symptoms: const ['high_fever', 'cough'],
    deniedSymptoms: const ['diarrhoea'],
    disease: disease,
    confidence: confidence,
    isUncertain: uncertain,
    followupRounds: 2,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('empty to start', () async {
    expect(await ConsultationHistoryService().load(), isEmpty);
  });

  test('a saved record comes back intact', () async {
    final service = ConsultationHistoryService();
    final at = DateTime(2026, 9, 7, 14, 30);
    await service.add(_record(id: 'a', at: at));

    final loaded = (await service.load()).single;
    expect(loaded.id, 'a');
    expect(loaded.timestamp, at);
    expect(loaded.symptoms, ['high_fever', 'cough']);
    expect(loaded.deniedSymptoms, ['diarrhoea']);
    expect(loaded.disease, 'Bronchial Asthma');
    expect(loaded.confidence, closeTo(0.77, 0.001));
    expect(loaded.followupRounds, 2);
  });

  test('an uncertain result stores no disease', () async {
    final service = ConsultationHistoryService();
    await service.add(_record(
      id: 'a',
      at: DateTime(2026, 9, 7),
      disease: null,
      confidence: null,
      uncertain: true,
    ));

    final loaded = (await service.load()).single;
    expect(loaded.isUncertain, isTrue);
    expect(loaded.disease, isNull,
        reason: 'no condition was shown, so none should be recorded');
    expect(loaded.confidence, isNull);
  });

  test('records come back newest first', () async {
    final service = ConsultationHistoryService();
    await service.add(_record(id: 'old', at: DateTime(2026, 9, 1)));
    await service.add(_record(id: 'new', at: DateTime(2026, 9, 7)));
    await service.add(_record(id: 'mid', at: DateTime(2026, 9, 4)));

    final ids = (await service.load()).map((r) => r.id).toList();
    expect(ids, ['new', 'mid', 'old']);
  });

  test('capped at maxRecords, dropping the oldest', () async {
    final service = ConsultationHistoryService();
    for (var i = 0; i < ConsultationHistoryService.maxRecords + 5; i++) {
      await service.add(_record(
        id: 'r$i',
        at: DateTime(2026, 1, 1).add(Duration(days: i)),
      ));
    }

    final records = await service.load();
    expect(records.length, ConsultationHistoryService.maxRecords);
    expect(records.first.id,
        'r${ConsultationHistoryService.maxRecords + 4}');
    expect(records.any((r) => r.id == 'r0'), isFalse,
        reason: 'the oldest records should have been dropped');
  });

  test('delete removes one record and leaves the rest', () async {
    final service = ConsultationHistoryService();
    await service.add(_record(id: 'a', at: DateTime(2026, 9, 1)));
    await service.add(_record(id: 'b', at: DateTime(2026, 9, 2)));

    await service.delete('a');

    final ids = (await service.load()).map((r) => r.id).toList();
    expect(ids, ['b']);
  });

  test('clear removes everything', () async {
    final service = ConsultationHistoryService();
    await service.add(_record(id: 'a', at: DateTime(2026, 9, 1)));
    await service.clear();
    expect(await service.load(), isEmpty);
  });

  test('count reflects what is stored', () async {
    final service = ConsultationHistoryService();
    expect(await service.count(), 0);
    await service.add(_record(id: 'a', at: DateTime(2026, 9, 1)));
    await service.add(_record(id: 'b', at: DateTime(2026, 9, 2)));
    expect(await service.count(), 2);
  });

  test('corrupt stored data reads as empty, not thrown', () async {
    SharedPreferences.setMockInitialValues(
        {'consultation_history': 'not valid json'});
    expect(await ConsultationHistoryService().load(), isEmpty);
  });
}
