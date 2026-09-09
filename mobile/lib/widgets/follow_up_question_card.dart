import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/symptom_matcher_service.dart';
import '../models/prediction_result.dart';
import '../models/symptom_severity.dart';

/// A round of follow-up questions, rendered inside a chat bubble.
///
/// A round is answered as a BATCH: answers are held locally until the user
/// submits, then applied together. Submitting one at a time used to advance
/// the round after a single tap and discard the rest of the questions.
///
/// Reports through [onSubmit] rather than calling ConsultationProvider
/// directly, so the hosting screen can also append a summary of what was
/// answered to the thread.
/// Severity labels come from the ARB rather than the enum, so they
/// follow the app language. The enum's own label stays English for
/// logging and storage.
/// The question as the user should read it.
///
/// Built here rather than in the orchestrator so the template follows the
/// app language. The orchestrator is part of the verified prediction path
/// and shouldn't be edited to solve a presentation problem; the symptom
/// column it provides is all this needs.
String questionText(AppText t, FollowUpQuestion question) {
  final label = SymptomMatcherService().getReadableLabel(question.symptom);
  return t.questionTemplate(label);
}

String severityLabel(AppText t, SymptomSeverity severity) {
  switch (severity) {
    case SymptomSeverity.mild:
      return t.severityMild;
    case SymptomSeverity.moderate:
      return t.severityModerate;
    case SymptomSeverity.severe:
      return t.severitySevere;
  }
}

class FollowUpQuestionCard extends StatefulWidget {
  final List<FollowUpQuestion> questions;
  final void Function(
    Map<String, bool> answers,
    Map<String, SymptomSeverity> severities,
  ) onSubmit;

  /// When true the round is already answered: render a static summary.
  final Map<String, bool>? submittedAnswers;

  /// Severities chosen with those answers, for the frozen summary.
  final Map<String, SymptomSeverity> submittedSeverities;

  const FollowUpQuestionCard({
    super.key,
    required this.questions,
    required this.onSubmit,
    this.submittedAnswers,
    this.submittedSeverities = const {},
  });

  @override
  State<FollowUpQuestionCard> createState() => _FollowUpQuestionCardState();
}

class _FollowUpQuestionCardState extends State<FollowUpQuestionCard> {
  final Map<String, bool> _answers = {};

  /// Optional - a user who doesn't want to grade a symptom just doesn't.
  final Map<String, SymptomSeverity> _severities = {};

  @override
  void didUpdateWidget(covariant FollowUpQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSymptoms = oldWidget.questions.map((q) => q.symptom).toList();
    final newSymptoms = widget.questions.map((q) => q.symptom).toList();
    if (!listEquals(oldSymptoms, newSymptoms)) {
      _answers.clear();
      _severities.clear();
    }
  }

  bool get _allAnswered => _answers.length == widget.questions.length;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final submitted = widget.submittedAnswers;
    if (submitted != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.questionsTitle,
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
                    child: Text(
                      widget.submittedSeverities[q.symptom] == null
                          ? questionText(t, q)
                          : "${questionText(t, q)}  \u00B7  "
                              "${severityLabel(t, widget.submittedSeverities[q.symptom]!)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
        Text(t.questionsTitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(t.questionsSubtitle,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        ...widget.questions.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(questionText(t, q),
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _choice(context, t.answerYes,
                          _answers[q.symptom] == true,
                          () => setState(() => _answers[q.symptom] = true)),
                      const SizedBox(width: 8),
                      _choice(context, t.answerNo,
                          _answers[q.symptom] == false,
                          () => setState(() {
                                _answers[q.symptom] = false;
                                // A denied symptom cannot have a severity.
                                _severities.remove(q.symptom);
                              })),
                    ],
                  ),
                  if (_answers[q.symptom] == true) ...[
                    const SizedBox(height: 8),
                    Text(t.severityPrompt,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: SymptomSeverity.values
                          .map((severity) => ChoiceChip(
                                label: Text(severityLabel(t, severity)),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                selected: _severities[q.symptom] == severity,
                                onSelected: (selected) => setState(() {
                                  if (selected) {
                                    _severities[q.symptom] = severity;
                                  } else {
                                    _severities.remove(q.symptom);
                                  }
                                }),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            )),
        Text(t.questionsAnsweredCount(answered, total),
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _allAnswered
                ? () => widget.onSubmit(
                    Map.of(_answers), Map.of(_severities))
                : null,
            child: Text(t.actionContinue),
          ),
        ),
        if (answered > 0 && !_allAnswered)
          TextButton(
            onPressed: () =>
                widget.onSubmit(Map.of(_answers), Map.of(_severities)),
            child: Text(t.actionSkipRest),
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
