import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/consultation_provider.dart';
import '../services/symptom_matcher_service.dart';

/// This screen's input mechanism is intentionally abstracted:
/// today, [_buildInputArea] returns a TextField. When Whisper-Tiny is
/// integrated, only [_buildInputArea] (and the matcher's text SOURCE)
/// changes - the rest of this screen (matching, prediction, follow-up
/// loop) stays identical, since it all operates on plain text either way.
class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final SymptomMatcherService _matcher = SymptomMatcherService();
  bool _matcherReady = false;
  String? _noMatchWarning;

  @override
  void initState() {
    super.initState();
    _matcher.initialize().then((_) {
      if (mounted) setState(() => _matcherReady = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (!_matcherReady) return;

    final matched = _matcher.matchSymptoms(_controller.text);

    if (matched.isEmpty) {
      setState(() {
        _noMatchWarning =
            "Couldn't recognize any symptoms in that text. Try describing them more simply, e.g. \"fever and cough\".";
      });
      return;
    }

    setState(() => _noMatchWarning = null);
    context.read<ConsultationProvider>().submitInitialSymptoms(matched);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Describe Your Symptoms")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Enter Symptoms", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        "TEMPORARY: typing for now, voice input (Whisper) comes in a later milestone.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputArea(),
                      const SizedBox(height: 10),
                      Text(
                        "Examples: \"fever and cough\" · \"headache, nausea\" · \"pet dard, ulti\"",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_noMatchWarning != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _noMatchWarning!,
                          style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _matcherReady ? () => _handleSubmit(context) : null,
                        child: const Text("Predict"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _ResultArea(), // temporary inline result display - see below
            ],
          ),
        ),
      ),
    );
  }

  /// TODAY: a TextField. LATER: replace this method's body with a mic
  /// button + Whisper transcription, still calling _handleSubmit with
  /// the resulting text. Nothing else in this screen needs to change.
  Widget _buildInputArea() {
    return TextField(
      controller: _controller,
      maxLines: 3,
      decoration: const InputDecoration(
        hintText: "e.g. I have fever and a cough",
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// TEMPORARY inline result display - NOT the real Prediction/Follow-up/
/// Advice/Doctor screens (those are separate upcoming milestones). This
/// exists only to verify the full pipeline works end-to-end right now.
class _ResultArea extends StatelessWidget {
  const _ResultArea();

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultationProvider>(
      builder: (context, provider, _) {
        switch (provider.status) {
          case ConsultationStatus.idle:
            return const SizedBox.shrink();

          case ConsultationStatus.loading:
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );

          case ConsultationStatus.error:
            return Card(
              color: AppTheme.danger.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Error: ${provider.errorMessage}\n\nIs the backend running? Check http://10.0.2.2:8000/docs",
                  style: const TextStyle(color: AppTheme.danger),
                ),
              ),
            );

          case ConsultationStatus.success:
            final result = provider.result!;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("[TEMP RESULT VIEW]",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Text(
                      "Top: ${result.topPrediction.disease} "
                      "(${(result.topPrediction.confidence * 100).toStringAsFixed(1)}%)",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    if (result.needsFollowup) ...[
                      Text("A few quick questions:", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      ...result.followUpQuestions.map((q) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(q.question)),
                                TextButton(
                                  onPressed: () => context
                                      .read<ConsultationProvider>()
                                      .answerFollowUp(q.symptom, true),
                                  child: const Text("Yes"),
                                ),
                                TextButton(
                                  onPressed: () => context
                                      .read<ConsultationProvider>()
                                      .answerFollowUp(q.symptom, false),
                                  child: const Text("No"),
                                ),
                              ],
                            ),
                          )),
                    ] else ...[
                      const Divider(),
                      Text("All predictions:", style: Theme.of(context).textTheme.bodyLarge),
                      ...result.allPredictions.take(3).map(
                            (p) => Text(
                              "${p.disease}: ${(p.confidence * 100).toStringAsFixed(1)}%",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
