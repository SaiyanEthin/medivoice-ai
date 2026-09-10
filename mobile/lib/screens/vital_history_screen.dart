import 'package:flutter/material.dart';
import '../core/date_format.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'vitals_screen.dart' show vitalLabel;
import '../core/unit_prefs.dart';
import '../models/vital_reading.dart';
import '../services/vitals_service.dart';

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
      appBar: AppBar(
          title: Text(vitalLabel(AppText.of(context), widget.type))),
      body: SafeArea(
        child: readings == null
            ? const Center(child: CircularProgressIndicator())
            : readings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(AppText.of(context).vitalsNotRecorded,
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
                                        Text(formatReading(reading),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge),
                                        const SizedBox(width: 4),
                                        Text(displayUnitFor(widget.type),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      relativeDay(reading.timestamp,
                                              AppText.of(context)) +
                                          ', ' +
                                          clockTime(reading.timestamp),
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
                                tooltip: AppText.of(context).actionDelete,
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
