import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/date_format.dart';
import '../core/theme/app_theme.dart';
import '../models/vital_reading.dart';
import '../services/vitals_service.dart';
import 'vital_history_screen.dart';


IconData iconFor(VitalType type) {
  switch (type) {
    case VitalType.bloodPressure:
      return Icons.monitor_heart_outlined;
    case VitalType.bloodGlucose:
      return Icons.water_drop_outlined;
    case VitalType.pulse:
      return Icons.favorite_border_rounded;
    case VitalType.oxygenSaturation:
      return Icons.air_rounded;
    case VitalType.temperature:
      return Icons.thermostat_outlined;
    case VitalType.weight:
      return Icons.monitor_weight_outlined;
  }
}

/// One screen for all six vitals. Each is recorded on its own - someone
/// who has just checked their blood pressure shouldn't have to invent
/// numbers for the other five.
class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _service = VitalsService();
  Map<VitalType, VitalReading?>? _latest;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final latest = await _service.latestOfEach();
    if (mounted) setState(() => _latest = latest);
  }

  Future<void> _addReading(VitalType type) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReadingSheet(type: type),
    );
    if (saved == true) _load();
  }

  Future<void> _openHistory(VitalType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VitalHistoryScreen(type: type)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final latest = _latest;
    return Scaffold(
      appBar: AppBar(title: const Text("Vitals")),
      body: SafeArea(
        child: latest == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            size: 18, color: AppTheme.primaryDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Readings are stored on this phone only. "
                            "MediVoice records what you enter - it does not "
                            "interpret the numbers or tell you whether a "
                            "reading is normal.",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...VitalType.values.map((type) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _VitalCard(
                          type: type,
                          latest: latest[type],
                          onAdd: () => _addReading(type),
                          onOpen: () => _openHistory(type),
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final VitalType type;
  final VitalReading? latest;
  final VoidCallback onAdd;
  final VoidCallback onOpen;

  const _VitalCard({
    required this.type,
    required this.latest,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final reading = latest;
    return Card(
      child: InkWell(
        onTap: reading == null ? onAdd : onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(iconFor(type), color: AppTheme.primaryDark, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    if (reading == null)
                      Text("Not recorded yet",
                          style: Theme.of(context).textTheme.bodySmall)
                    else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(reading.formatted,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(width: 4),
                          Text(type.unit,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      Text("Last recorded: ${relativeDay(reading.timestamp)}",
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onAdd,
                tooltip: "Add reading",
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddReadingSheet extends StatefulWidget {
  final VitalType type;
  const _AddReadingSheet({required this.type});

  @override
  State<_AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends State<_AddReadingSheet> {
  final _service = VitalsService();
  final _primary = TextEditingController();
  final _secondary = TextEditingController();
  final _note = TextEditingController();
  String? _error;
  bool _saving = false;

  /// Defaults to today. Kept as a date only - the exact minute of a
  /// reading logged after the fact is guesswork, so it isn't asked for.
  DateTime _when = DateTime.now();

  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      // Two years back is more than enough for a health log, and a future
      // date would be a reading that hasn't happened.
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) setState(() => _when = picked);
  }

  /// Midnight for a past date; the actual time for today, so several
  /// readings logged on the same day still order correctly.
  DateTime get _timestamp {
    final now = DateTime.now();
    final isToday = _when.year == now.year &&
        _when.month == now.month &&
        _when.day == now.day;
    return isToday ? now : DateTime(_when.year, _when.month, _when.day, 12);
  }

  Future<void> _save() async {
    final type = widget.type;
    final primary = double.tryParse(_primary.text.trim());
    if (primary == null) {
      setState(() =>
          _error = "Enter a number for ${type.primaryFieldLabel.toLowerCase()}.");
      return;
    }

    final range = type.plausibleRange;
    if (primary < range.$1 || primary > range.$2) {
      setState(() => _error =
          "That doesn't look like a ${type.label.toLowerCase()} reading. "
          "Expected roughly ${range.$1.toStringAsFixed(0)} to "
          "${range.$2.toStringAsFixed(0)} ${type.unit}.");
      return;
    }

    double? secondary;
    if (type.hasSecondary) {
      secondary = double.tryParse(_secondary.text.trim());
      if (secondary == null) {
        setState(() => _error = "Enter a diastolic value too.");
        return;
      }
      final sRange = type.secondaryPlausibleRange;
      if (secondary < sRange.$1 || secondary > sRange.$2) {
        setState(() => _error = "That diastolic value looks out of range.");
        return;
      }
      if (secondary >= primary) {
        setState(() => _error =
            "Diastolic is usually lower than systolic - please check.");
        return;
      }
    }

    setState(() => _saving = true);
    await _service.add(VitalReading(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      timestamp: _timestamp,
      value: primary,
      secondaryValue: secondary,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(type.label,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text("Measured in ${type.unit}",
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _primary,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration:
                        InputDecoration(labelText: type.primaryFieldLabel),
                  ),
                ),
                if (type.hasSecondary) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _secondary,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                          labelText: type.secondaryFieldLabel),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_outlined,
                        size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Recorded ${relativeDay(_when).toLowerCase()}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Text("Change",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Note (optional)",
                hintText: "e.g. before food, after a walk",
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      const TextStyle(color: AppTheme.danger, fontSize: 13)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: const Text("Save reading"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
