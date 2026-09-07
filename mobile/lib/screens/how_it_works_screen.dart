import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Walks through what happens during a consultation.
///
/// Every step here runs on the phone - that is the whole point of the
/// project, and it is worth showing rather than just claiming.
class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  static const _steps = <_StepData>[
    _StepData(
      icon: Icons.mic_rounded,
      title: "You speak",
      body: "Describe how you're feeling in Kannada, Hindi or English. "
          "You can type instead if you'd rather.",
    ),
    _StepData(
      icon: Icons.graphic_eq_rounded,
      title: "Your phone listens",
      body: "Speech becomes text using a compact recognition model running "
          "on the device itself. Your voice is never uploaded.",
    ),
    _StepData(
      icon: Icons.search_rounded,
      title: "Symptoms are identified",
      body: "What you said is matched against a multilingual symptom "
          "vocabulary. Saying you DON'T have something counts too.",
    ),
    _StepData(
      icon: Icons.help_outline_rounded,
      title: "A few questions",
      body: "If there isn't enough to go on, you'll be asked a short set of "
          "yes/no questions chosen to narrow the possibilities.",
    ),
    _StepData(
      icon: Icons.insights_rounded,
      title: "A preliminary assessment",
      body: "A lightweight model suggests what the pattern may be "
          "consistent with. If it isn't confident, it says so instead of "
          "guessing.",
    ),
    _StepData(
      icon: Icons.local_hospital_outlined,
      title: "Guidance and next steps",
      body: "Practical self-care suggestions, warning signs to watch for, "
          "and the kind of specialist worth seeing.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("How MediVoice Works")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              "A consultation, step by step",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Everything below happens on your phone.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < _steps.length; i++)
              _StepTile(
                index: i + 1,
                data: _steps[i],
                isLast: i == _steps.length - 1,
              ),
            const SizedBox(height: 8),
            _NoteCard(
              icon: Icons.lock_outline_rounded,
              color: AppTheme.primary,
              title: "Your consultation stays with you",
              body: "Symptoms, recordings and results are never sent "
                  "anywhere. The app works with the network switched off - "
                  "apart from a one-time download of the speech model when "
                  "you first use it.",
            ),
            const SizedBox(height: 12),
            _NoteCard(
              icon: Icons.info_outline_rounded,
              color: AppTheme.danger,
              title: "This is not a diagnosis",
              body: "MediVoice matches patterns against training data to "
                  "raise awareness. It cannot examine you, it covers a "
                  "limited set of conditions, and it is not a substitute "
                  "for a qualified doctor.",
            ),
          ],
        ),
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String title;
  final String body;
  const _StepData({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _StepTile extends StatelessWidget {
  final int index;
  final _StepData data;
  final bool isLast;

  const _StepTile({
    required this.index,
    required this.data,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: AppTheme.primary, size: 22),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppTheme.primary.withOpacity(0.18),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 20 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$index. ${data.title}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _NoteCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: color)),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
