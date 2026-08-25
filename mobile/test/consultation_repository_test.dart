import 'package:flutter_test/flutter_test.dart';
import 'package:medivoice_ai/repositories/consultation_repository.dart';
import 'package:medivoice_ai/services/symptom_matcher_service.dart';

/// End-to-end test of the FULL offline chain: ConsultationRepository ->
/// ConsultationOrchestratorService -> DiseasePredictorService, including
/// the two-gate follow-up logic - not just the raw model math.
///
/// Uses the exact symptoms/result we already saw live in the running app
/// (screenshot, 2026-08-24): fever+cough+fatigue -> Bronchial Asthma 72.9%,
/// no follow-up needed (3 symptoms clears Gate 1, 0.7292 clears the 0.65
/// Gate 2 threshold).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('full offline chain matches previously observed live app result', () async {
    // SymptomMatcherService is needed by the orchestrator for follow-up
    // question text - initialize it too, same as VoiceInputScreen does.
    await SymptomMatcherService().initialize();

    final repository = ConsultationRepository();
    final result = await repository.getPrediction(
      symptoms: ['high_fever', 'cough', 'fatigue'],
    );

    print('Top prediction: ${result.topPrediction.disease} '
        '(${result.topPrediction.confidence})');
    print('Needs follow-up: ${result.needsFollowup}');

    expect(result.topPrediction.disease, 'Bronchial Asthma');
    expect(result.topPrediction.confidence - 0.7292, closeTo(0, 0.001));
    expect(result.needsFollowup, false);
    expect(result.isUncertain, false);
  });

  test('too few symptoms triggers a follow-up question (Gate 1)', () async {
    await SymptomMatcherService().initialize();

    final repository = ConsultationRepository();
    final result = await repository.getPrediction(symptoms: ['high_fever']);

    print('Needs follow-up: ${result.needsFollowup}, '
        'questions: ${result.followUpQuestions.map((q) => q.question).toList()}');

    expect(result.needsFollowup, true);
    expect(result.followUpQuestions, isNotEmpty);
  });
}
