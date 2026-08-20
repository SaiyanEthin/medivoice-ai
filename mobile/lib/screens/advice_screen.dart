import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/advice.dart';
import '../repositories/consultation_repository.dart';

/// Shows rule-based health advice for a given condition.
/// Advice is fully deterministic (no LLM) - each condition maps to a
/// fixed, reviewed set of guidance in backend/database/advice_templates.json.
class AdviceScreen extends StatefulWidget {
  final String disease;

  const AdviceScreen({super.key, required this.disease});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  final ConsultationRepository _repository = ConsultationRepository();
  Advice? _advice;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final advice = await _repository.getAdvice(widget.disease);
      if (mounted) setState(() { _advice = advice; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Advice")),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 40, color: AppTheme.danger),
              const SizedBox(height: 12),
              Text("Couldn't load advice.\n$_error",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    final advice = _advice!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SeverityBanner(advice: advice),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recommended steps",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  ...advice.advice.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Text("${entry.key + 1}",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryDark)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(entry.value,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
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
                      "This is general guidance only, not a prescription. "
                      "Do not start or stop any medication without consulting "
                      "a qualified doctor.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text("Back to Assessment"),
          ),
        ],
      ),
    );
  }
}

class _SeverityBanner extends StatelessWidget {
  final Advice advice;
  const _SeverityBanner({required this.advice});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String label;

    switch (advice.level) {
      case SeverityLevel.serious:
        color = AppTheme.danger;
        icon = Icons.warning_amber_rounded;
        label = "Seek medical attention promptly";
        break;
      case SeverityLevel.chronic:
        color = AppTheme.accent;
        icon = Icons.monitor_heart_outlined;
        label = "Ongoing condition - needs monitoring";
        break;
      case SeverityLevel.moderate:
        color = AppTheme.accent;
        icon = Icons.info_outline_rounded;
        label = "Moderate - monitor closely";
        break;
      case SeverityLevel.mild:
        color = AppTheme.success;
        icon = Icons.check_circle_outline_rounded;
        label = "Usually mild and self-limiting";
        break;
    }

    return Card(
      color: color.withOpacity(0.10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Advice for", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(advice.disease,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}