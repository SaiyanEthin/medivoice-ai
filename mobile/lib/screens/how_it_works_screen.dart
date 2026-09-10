import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Walks through what happens during a consultation.
///
/// Every step here runs on the phone - that is the whole point of the
/// project, and it is worth showing rather than just claiming.
class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  /// Built at runtime rather than held as a const: AppText values are
  /// not compile-time constants, so the list has to be created once the
  /// localisations are in scope.
  static List<_StepData> _steps(AppText t) => [
        _StepData(
          icon: Icons.mic_rounded,
          title: t.howStep1Title,
          body: t.howStep1Body,
        ),
        _StepData(
          icon: Icons.graphic_eq_rounded,
          title: t.howStep2Title,
          body: t.howStep2Body,
        ),
        _StepData(
          icon: Icons.search_rounded,
          title: t.howStep3Title,
          body: t.howStep3Body,
        ),
        _StepData(
          icon: Icons.help_outline_rounded,
          title: t.howStep4Title,
          body: t.howStep4Body,
        ),
        _StepData(
          icon: Icons.insights_rounded,
          title: t.howStep5Title,
          body: t.howStep5Body,
        ),
        _StepData(
          icon: Icons.local_hospital_outlined,
          title: t.howStep6Title,
          body: t.howStep6Body,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    final steps = _steps(t);
    return Scaffold(
      appBar: AppBar(title: Text(t.howToTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              AppText.of(context).howToHeading,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppText.of(context).howToSubheading,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < steps.length; i++)
              _StepTile(
                index: i + 1,
                data: steps[i],
                isLast: i == steps.length - 1,
              ),
            const SizedBox(height: 8),
            _NoteCard(
              icon: Icons.lock_outline_rounded,
              color: AppTheme.primary,
              title: t.howPrivacyTitle,
              body: t.howPrivacyBody,
            ),
            const SizedBox(height: 12),
            _NoteCard(
              icon: Icons.info_outline_rounded,
              color: AppTheme.danger,
              title: t.howNotDiagnosisTitle,
              body: t.howNotDiagnosisBody,
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
                    AppText.of(context)
                        .howStepNumbered(index, data.title),
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
