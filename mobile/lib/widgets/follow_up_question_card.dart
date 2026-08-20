import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/prediction_result.dart';
import '../providers/consultation_provider.dart';

/// Isolated on purpose: the Prediction Screen should stay clean and only
/// deal with FINAL results. This widget owns all follow-up question
/// UI/logic and is used from the Voice Input Screen while a consultation
/// is still being resolved (not shown on the final Prediction Screen).
class FollowUpQuestionCard extends StatelessWidget {
  final List<FollowUpQuestion> questions;

  const FollowUpQuestionCard({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
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
                  child: Text("A few quick questions", style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "This helps narrow down the assessment.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...questions.map((q) => _QuestionRow(question: q)),
          ],
        ),
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final FollowUpQuestion question;
  const _QuestionRow({required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(question.question, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () =>
                context.read<ConsultationProvider>().answerFollowUp(question.symptom, true),
            child: const Text("Yes"),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () =>
                context.read<ConsultationProvider>().answerFollowUp(question.symptom, false),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }
}
