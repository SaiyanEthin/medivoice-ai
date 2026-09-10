import 'package:flutter/material.dart';
import '../core/date_format.dart';
import '../core/disease_display.dart';
import '../core/theme/app_theme.dart';
import '../models/consultation_record.dart';
import '../l10n/app_localizations.dart';
import '../widgets/follow_up_question_card.dart' show severityLabel;
import '../services/consultation_history_service.dart';
import '../services/symptom_matcher_service.dart';

/// Past assessments, newest first.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = ConsultationHistoryService();
  final _matcher = SymptomMatcherService();
  List<ConsultationRecord>? _records;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // The matcher may not be initialised if this screen is opened before
    // any consultation this session.
    await _matcher.initialize();
    final records = await _service.load();
    if (mounted) setState(() => _records = records);
  }

  Future<void> _delete(ConsultationRecord record) async {
    await _service.delete(record.id);
    await _load();
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.of(context).historyDeleteAllTitle),
        content: Text(AppText.of(context).historyDeleteAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppText.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: Text(AppText.of(context).actionDeleteAll),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clear();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).historyTitle),
        actions: [
          if (records != null && records.isNotEmpty)
            IconButton(
              onPressed: _confirmClearAll,
              tooltip: AppText.of(context).historyDeleteAllTooltip,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: records == null
            ? const Center(child: CircularProgressIndicator())
            : records.isEmpty
                ? _buildEmpty(context)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _RecordCard(
                      record: records[i],
                      matcher: _matcher,
                      onDelete: () => _delete(records[i]),
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded,
                size: 48, color: AppTheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(AppText.of(context).historyEmptyTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              AppText.of(context).historyEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final ConsultationRecord record;
  final SymptomMatcherService matcher;
  final VoidCallback onDelete;

  const _RecordCard({
    required this.record,
    required this.matcher,
    required this.onDelete,
  });

  /// Uses the shared date helpers rather than a third private copy of
  /// month names, so it follows the app language too.
  String get _formattedDate =>
      '${shortDate(record.timestamp)}, ${clockTime(record.timestamp)}';

  /// De-duplicated by label: several columns deliberately share phrases,
  /// so one complaint can otherwise appear as two or three chips.
  List<String> get _labels {
    final seen = <String>[];
    for (final symptom in record.symptoms) {
      final label = matcher.getReadableLabel(symptom);
      if (!seen.contains(label)) seen.add(label);
    }
    return seen;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(_formattedDate,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    onSelected: (_) => onDelete(),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(AppText.of(context).actionDelete),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (record.isUncertain) ...[
              Text(AppText.of(context).historySymptomsUnclear,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(AppText.of(context).historyNoMatch,
                  style: Theme.of(context).textTheme.bodyMedium),
            ] else ...[
              Text(diseaseDisplayName(record.disease ?? ''),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                AppText.of(context).resultScoreLine(
                    ((record.confidence ?? 0) * 100).toStringAsFixed(1)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _labels
                  .map((label) => Chip(
                        label: Text(label),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
            if (record.severities.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(AppText.of(context).historyReportedSeverity,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              ...record.severities.entries.map((entry) => Text(
                    '${matcher.getReadableLabel(entry.key)} '
                    '\u2014 ${severityLabel(AppText.of(context), entry.value)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
            ],
            if (record.deniedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppText.of(context).historyRuledOut(
                    record.deniedSymptoms.length, record.followupRounds),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
