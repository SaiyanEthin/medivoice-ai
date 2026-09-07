import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/vital_reading.dart';
import '../services/vitals_service.dart';

/// "Today", "Yesterday", or a short date. Relative wording is easier to
/// scan than a bare date when the question is "how recent is this".
String relativeDay(DateTime when) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(when.year, when.month, when.day);
  final difference = today.difference(day).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  if (difference < 7) return '$difference days ago';
  return '${when.day} ${months[when.month - 1]} ${when.year}';
}

String clockTime(DateTime when) {
  final hour = when.hour % 12 == 0 ? 12 : when.hour % 12;
  final minute = when.minute.toString().padLeft(2, '0');
  final period = when.hour < 12 ? 'am' : 'pm';
  return '$hour:$minute$period';
}

/// Every recorded reading for one vital, newest first.
class VitalHistoryScreen extends StatefulWidget {
  final VitalType type;
  const VitalHistoryScreen({super.key, required this.type});

  @override
  State<VitalHistoryScreen> createState() => _VitalHistoryScreenState();
}

class _VitalHistoryScreenState extends State<VitalHistoryScreen> {
  final _service = VitalsService();
  List<VitalReading>? _readings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final readings = await _service.loadByType(widget.type);
    if (mounted) setState(() => _readings = readings);
  }

  Future<void> _delete(VitalReading reading) async {
    await _service.delete(reading.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final readings = _readings;
    return Scaffold(
      appBar: AppBar(title: Text(widget.type.label)),
      body: SafeArea(
        child: readings == null
            ? const Center(child: CircularProgressIndicator())
            : readings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text("No readings recorded yet.",
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    itemCount: readings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final reading = readings[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(reading.formatted,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge),
                                        const SizedBox(width: 4),
                                        Text(widget.type.unit,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${relativeDay(reading.timestamp)}, "
                                      "${clockTime(reading.timestamp)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    if (reading.note != null) ...[
                                      const SizedBox(height: 4),
                                      Text(reading.note!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _delete(reading),
                                tooltip: "Delete",
                                icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
