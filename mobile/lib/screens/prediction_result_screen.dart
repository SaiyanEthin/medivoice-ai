import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/disease_display.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/consultation_provider.dart';
import '../services/selfcare_guidance_service.dart';
import '../services/symptom_matcher_service.dart';
import 'advice_screen.dart';
import 'doctor_list_screen.dart';

/// The real Prediction Screen. Only reached once ConsultationProvider has
/// a FINAL result (no more follow-ups pending). Handles two states:
///   1. Uncertain  -> never names a condition, shows general guidance
///   2. Confident  -> shows "Possible condition" + score + navigation
class PredictionResultScreen extends StatelessWidget {
  const PredictionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsultationProvider>();
    final result = provider.result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).resultAppBarFallback)),
        body: Center(child: Text(AppText.of(context).resultNoResult)),
      );
    }

    final matcher = SymptomMatcherService();
    // De-duplicated by display LABEL, not by symptom column. Several
    // columns deliberately share phrases in the symptom dictionary
    // (abdominal_pain / belly_pain / stomach_pain all match "stomach
    // pain"), so one complaint would otherwise render as three chips,
    // two of them reading identically. The provider still holds every
    // column and the model still scores on all of them - only the chip
    // row collapses them.
    final recognizedLabels = <String>[];
    for (final symptom in provider.symptoms) {
      final label = matcher.getReadableLabel(symptom);
      if (!recognizedLabels.contains(label)) recognizedLabels.add(label);
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppText.of(context).resultAppBarTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (result.isUncertain)
                _UncertainCard(
                  reason: result.uncertaintyReason,
                  symptoms: provider.symptoms,
                )
              else
                _AssessmentCard(
                  disease: result.topPrediction.disease,
                  confidence: result.topPrediction.confidence,
                ),

              const SizedBox(height: 16),
              _RecognizedSymptomsCard(labels: recognizedLabels),
              const SizedBox(height: 16),
              const _DisclaimerCard(),
              const SizedBox(height: 24),

              // Advice/Doctors only make sense when we actually have a condition
              if (!result.isUncertain) ...[
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdviceScreen(
                        disease: result.topPrediction.disease,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.health_and_safety_outlined),
                  label: Text(AppText.of(context).actionViewAdvice),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorListScreen(
                        disease: result.topPrediction.disease,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.local_hospital_outlined),
                  label: Text(AppText.of(context).actionFindDoctors),
                ),
                const SizedBox(height: 10),
              ],

              TextButton.icon(
                onPressed: () {
                  provider.reset();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppText.of(context).actionTryAgain),
              ),

              if (kDebugMode) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  "[DEBUG] uncertain=${result.isUncertain} reason=${result.uncertaintyReason} "
                  "round=${result.followupRound}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text("[DEBUG] Full ranked predictions:",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ...result.allPredictions.map(
                  (p) => Text(
                    "${p.disease}: ${(p.confidence * 100).toStringAsFixed(1)}%",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when the model doesn't have enough evidence or confidence.
/// Deliberately does NOT name any condition.
class _UncertainCard extends StatelessWidget {
  final String? reason;
  final List<String> symptoms;
  const _UncertainCard({this.reason, required this.symptoms});

  @override
  Widget build(BuildContext context) {
    final explanation = reason == "insufficient_symptoms"
        ? AppText.of(context).uncertainInsufficient
        : AppText.of(context).uncertainLowConfidence;

    // Rule-based, offline. Falls back to generic bullets if the asset
    // hasn't loaded, so this card can never render empty.
    final guidance = SelfCareGuidanceService().guidanceFor(symptoms);
    final careBullets = guidance?.guidance ??
        const [
          "Rest and drink plenty of fluids",
          "Monitor your symptoms over the next 24-48 hours",
          "See a doctor if symptoms worsen or persist beyond a few days",
        ];
    final redFlags = guidance?.redFlags ??
        const [
          "Difficulty breathing or shortness of breath",
          "Chest pain or pressure",
          "Confusion, fainting, or difficulty staying awake",
          "Symptoms that are severe or getting worse quickly",
        ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppText.of(context).uncertainCardTitle,
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(explanation, style: Theme.of(context).textTheme.bodyLarge),

            const SizedBox(height: 20),
            Text(AppText.of(context).uncertainWhatYouCanDo,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...careBullets.map((t) => _Bullet(text: t)),

            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 20, color: AppTheme.danger),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(AppText.of(context).uncertainSeekCare,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...redFlags.map((t) => _Bullet(text: t, color: AppTheme.danger)),

            const SizedBox(height: 16),
            const SizedBox(height: 18),
            Text(AppText.of(context).unclearFindGpExplain,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DoctorListScreen.general()),
                ),
                icon: const Icon(Icons.local_hospital_outlined, size: 18),
                label: Text(AppText.of(context).unclearFindGp),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              guidance?.disclaimer ??
                  "This is general supportive guidance for comfort only. It does "
                      "not diagnose or treat any condition.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color? color;
  const _Bullet({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\u2022  ", style: TextStyle(color: color)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final String disease;
  final double confidence;
  const _AssessmentCard({required this.disease, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppText.of(context).resultPossibleCondition,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(diseaseDisplayName(disease),
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.insights_rounded, size: 18, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(AppText.of(context).resultScoreLine(pct),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              // Two complete sentences rather than a word slotted into
              // one: inserting "fairly confident" mid-sentence does not
              // survive translation, since word order differs.
              confidence >= 0.70
                  ? AppText.of(context)
                      .resultBodyFairlyConfident(diseaseDisplayName(disease))
                  : AppText.of(context).resultBodyModeratelyConfident(
                      diseaseDisplayName(disease)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecognizedSymptomsCard extends StatelessWidget {
  final List<String> labels;
  const _RecognizedSymptomsCard({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppText.of(context).resultRecognizedSymptoms,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: labels
                  .map((label) => Chip(
                        label: Text(label),
                        backgroundColor: AppTheme.primary.withOpacity(0.08),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.accent.withOpacity(0.10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.primaryDark),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppText.of(context).resultDisclaimer,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}