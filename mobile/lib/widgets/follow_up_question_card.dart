import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/prediction_result.dart';

/// A round of follow-up questions, rendered inside a chat bubble.
///
/// A round is answered as a BATCH: answers are held locally until the user
/// submits, then applied together. Submitting one at a time used to advance
/// the round after a single tap and discard the rest of the questions.
///
/// Reports through [onSubmit] rather than calling ConsultationProvider
/// directly, so the hosting screen can also append a summary of what was
/// answered to the thread.
class FollowUpQuestionCard extends StatefulWidget {
  final List<FollowUpQuestion> questions;
  final void Function(Map<String, bool> answers) onSubmit;

  /// When true the round is already answered: render a static summary.
  final Map<String, bool>? submittedAnswers;

  const FollowUpQuestionCard({
    super.key,
    required this.questions,
    required this.onSubmit,
    this.submittedAnswers,
  });

  @override
  State<FollowUpQuestionCard> createState() => _FollowUpQuestionCardState();
}

class _FollowUpQuestionCardState extends State<FollowUpQuestionCard> {
  final Map<String, bool> _answers = {};

  @override
  void didUpdateWidget(covariant FollowUpQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSymptoms = oldWidget.questions.map((q) => q.symptom).toList();
    final newSymptoms = widget.questions.map((q) => q.symptom).toList();
    if (!listEquals(oldSymptoms, newSymptoms)) {
      _answers.clear();
    }
  }

  bool get _allAnswered => _answers.length == widget.questions.length;

  @override
  Widget build(BuildContext context) {
    final submitted = widget.submittedAnswers;
    if (submitted != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("A few quick questions",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...widget.questions.map((q) {
            final a = submitted[q.symptom];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    a == null
                        ? Icons.remove_circle_outline
                        : (a ? Icons.check_circle : Icons.cancel_outlined),
                    size: 18,
                    color: a == null
                        ? Colors.grey
                        : (a ? AppTheme.primary : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(q.question,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    final answered = _answers.length;
    final total = widget.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("A few quick questions",
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text("This helps narrow things down.",
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        ...widget.questions.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.question,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _choice(context, "Yes", _answers[q.symptom] == true,
                          () => setState(() => _answers[q.symptom] = true)),
                      const SizedBox(width: 8),
                      _choice(context, "No", _answers[q.symptom] == false,
                          () => setState(() => _answers[q.symptom] = false)),
                    ],
                  ),
                ],
              ),
            )),
        Text("$answered of $total answered",
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _allAnswered ? () => widget.onSubmit(Map.of(_answers)) : null,
            child: const Text("Continue"),
          ),
        ),
        if (answered > 0 && !_allAnswered)
          TextButton(
            onPressed: () => widget.onSubmit(Map.of(_answers)),
            child: const Text("Skip the rest"),
          ),
      ],
    );
  }

  Widget _choice(
      BuildContext context, String label, bool selected, VoidCallback onTap) {
    return selected
        ? ElevatedButton(onPressed: onTap, child: Text(label))
        : OutlinedButton(onPressed: onTap, child: Text(label));
  }
}
