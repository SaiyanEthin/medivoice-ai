import 'package:flutter/material.dart';
import '../core/disease_display.dart';
import '../core/theme/app_theme.dart';
import '../models/consultation_record.dart';
import '../models/symptom_severity.dart';
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
        title: const Text("Delete all assessments?"),
        content: const Text(
            "This removes every saved assessment from this phone. It "
            "cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text("Delete all"),
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
        title: const Text("Past assessments"),
        actions: [
          if (records != null && records.isNotEmpty)
            IconButton(
              onPressed: _confirmClearAll,
              tooltip: "Delete all",
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
            Text("No assessments yet",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              "Once you complete a consultation it will be saved here so "
              "you can look back at it later.",
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

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _formattedDate {
    final t = record.timestamp;
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'am' : 'pm';
    return "${t.day} ${_months[t.month - 1]} ${t.year}, $hour:$minute$period";
  }

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
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (record.isUncertain) ...[
              Text("Symptoms unclear",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text("No single condition matched clearly",
                  style: Theme.of(context).textTheme.bodyMedium),
            ] else ...[
              Text(diseaseDisplayName(record.disease ?? ''),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                "Model score: "
                "${((record.confidence ?? 0) * 100).toStringAsFixed(1)}%",
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
              Text("Reported severity",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              ...record.severities.entries.map((entry) => Text(
                    "${matcher.getReadableLabel(entry.key)} "
                    "\u2014 ${entry.value.label}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
            ],
            if (record.deniedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "${record.deniedSymptoms.length} symptom(s) ruled out over "
                "${record.followupRounds} follow-up round(s)",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
