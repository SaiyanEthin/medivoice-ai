import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/consultation_provider.dart';
import '../services/symptom_matcher_service.dart';
import 'placeholder_screen.dart';
import 'advice_screen.dart';

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
        appBar: AppBar(title: const Text("Assessment")),
        body: const Center(child: Text("No result available.")),
      );
    }

    final matcher = SymptomMatcherService();
    final recognizedLabels = provider.symptoms.map(matcher.getReadableLabel).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Preliminary Health Assessment")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (result.isUncertain)
                _UncertainCard(reason: result.uncertaintyReason)
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
                  label: const Text("View Health Advice"),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlaceholderScreen(title: "Find Doctors"),
                    ),
                  ),
                  icon: const Icon(Icons.local_hospital_outlined),
                  label: const Text("Find Doctors"),
                ),
                const SizedBox(height: 10),
              ],

              TextButton.icon(
                onPressed: () {
                  provider.reset();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Try Again"),
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
  const _UncertainCard({this.reason});

  @override
  Widget build(BuildContext context) {
    final explanation = reason == "insufficient_symptoms"
        ? "You described only a few symptoms, which isn't enough to suggest "
          "a specific condition. Many everyday causes can produce these symptoms."
        : "Your symptoms don't clearly match any single condition this app "
          "can assess. This is common with mild or early-stage illness.";

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
                  child: Text("Symptoms Unclear",
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(explanation, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text("General care", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...[
              "Rest and drink plenty of fluids",
              "Monitor your symptoms over the next 24-48 hours",
              "See a doctor if symptoms worsen or persist beyond a few days",
              "Seek care immediately if you have difficulty breathing, chest pain, "
                  "or a very high fever",
            ].map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("•  "),
                      Expanded(child: Text(t, style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                )),
          ],
        ),
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
    final confidenceWord = confidence >= 0.70 ? "fairly confident" : "moderately confident";

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Possible condition", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(disease, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.insights_rounded, size: 18, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text("Model score: $pct%", style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Based on the symptoms you described, the model is $confidenceWord "
              "these may be consistent with $disease. This is a pattern match "
              "against training data, not a medical diagnosis.",
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
            Text("Recognized Symptoms", style: Theme.of(context).textTheme.titleLarge),
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
                "This is a preliminary, non-diagnostic assessment generated by an "
                "AI model. It is not a substitute for professional medical advice. "
                "Please consult a qualified doctor for accurate diagnosis and treatment.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}