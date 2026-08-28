import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/prediction_result.dart';
import '../providers/consultation_provider.dart';

/// Isolated on purpose: the Prediction Screen should stay clean and only
/// deal with FINAL results. This widget owns all follow-up question
/// UI/logic and is used from the Voice Input Screen while a consultation
/// is still being resolved (not shown on the final Prediction Screen).
///
/// Stateful because a round of questions is answered as a BATCH. Answers
/// are held locally until submitted, then applied together in one call.
/// Previously each button submitted immediately, which advanced the round
/// after a single answer and discarded the rest of the questions.
class FollowUpQuestionCard extends StatefulWidget {
  final List<FollowUpQuestion> questions;

  const FollowUpQuestionCard({super.key, required this.questions});

  @override
  State<FollowUpQuestionCard> createState() => _FollowUpQuestionCardState();
}

class _FollowUpQuestionCardState extends State<FollowUpQuestionCard> {
  /// symptom column -> answer. Absent means "not answered yet".
  final Map<String, bool> _answers = {};

  @override
  void didUpdateWidget(covariant FollowUpQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Flutter reuses this State object across rounds, so clear stale
    // answers when a new set of questions arrives.
    final oldSymptoms = oldWidget.questions.map((q) => q.symptom).toList();
    final newSymptoms = widget.questions.map((q) => q.symptom).toList();
    if (!listEquals(oldSymptoms, newSymptoms)) {
      _answers.clear();
    }
  }

  bool get _allAnswered => _answers.length == widget.questions.length;

  void _submit() {
    // Copy: the provider triggers a rebuild that may clear _answers.
    context.read<ConsultationProvider>().answerFollowUpBatch(Map.of(_answers));
  }

  @override
  Widget build(BuildContext context) {
    final answered = _answers.length;
    final total = widget.questions.length;

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
                  child: Text("A few quick questions",
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "This helps narrow down the assessment.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...widget.questions.map((q) => _QuestionRow(
                  question: q,
                  answer: _answers[q.symptom],
                  onAnswer: (value) => setState(() => _answers[q.symptom] = value),
                )),
            const SizedBox(height: 8),
            Text(
              "$answered of $total answered",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _allAnswered ? _submit : null,
              child: const Text("Continue"),
            ),
            if (answered > 0 && !_allAnswered) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: _submit,
                child: const Text("Skip the rest"),
              ),
              Text(
                "Skipped questions are ignored, not counted as \"No\".",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final FollowUpQuestion question;
  final bool? answer;
  final ValueChanged<bool> onAnswer;

  const _QuestionRow({
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(question.question,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 8),
          _choice(context, "Yes", answer == true, () => onAnswer(true)),
          const SizedBox(width: 8),
          _choice(context, "No", answer == false, () => onAnswer(false)),
        ],
      ),
    );
  }

  /// Selected answers render filled so the user can see what they picked
  /// before committing the round.
  Widget _choice(BuildContext context, String label, bool selected,
      VoidCallback onTap) {
    return selected
        ? ElevatedButton(onPressed: onTap, child: Text(label))
        : OutlinedButton(onPressed: onTap, child: Text(label));
  }
}
