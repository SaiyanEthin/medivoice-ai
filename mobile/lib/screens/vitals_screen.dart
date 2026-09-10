import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/date_format.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../core/unit_prefs.dart';
import '../models/vital_reading.dart';
import '../services/vitals_service.dart';
import 'trends_screen.dart';
import 'vital_history_screen.dart';


/// Display name for a vital. VitalType.label stays English - the enum
/// is storage vocabulary, and only what the user reads is translated.
String vitalLabel(AppText t, VitalType type) {
  switch (type) {
    case VitalType.bloodPressure:
      return t.vitalBloodPressure;
    case VitalType.bloodGlucose:
      return t.vitalBloodGlucose;
    case VitalType.pulse:
      return t.vitalPulse;
    case VitalType.oxygenSaturation:
      return t.vitalOxygen;
    case VitalType.temperature:
      return t.vitalTemperature;
    case VitalType.weight:
      return t.vitalWeight;
  }
}

/// The label for the value field. Blood pressure has two numbers, and on
/// a home monitor they are simply the upper and lower ones.
String vitalFieldLabel(AppText t, VitalType type) =>
    type == VitalType.bloodPressure ? t.vitalBpUpper : vitalLabel(t, type);

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

  Future<void> _openUnits() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UnitsSheet(),
    );
    if (changed == true) _load();
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
      appBar: AppBar(
        title: Text(AppText.of(context).vitalsTitle),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrendsScreen()),
            ),
            tooltip: AppText.of(context).vitalsTrendsTooltip,
            icon: const Icon(Icons.show_chart_rounded),
          ),
          IconButton(
            onPressed: _openUnits,
            tooltip: AppText.of(context).vitalsUnitsTooltip,
            icon: const Icon(Icons.straighten_rounded),
          ),
        ],
      ),
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
                            AppText.of(context).vitalsPrivacyNote,
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
                    Text(vitalLabel(AppText.of(context), type),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    if (reading == null)
                      Text(AppText.of(context).vitalsNotRecorded,
                          style: Theme.of(context).textTheme.bodySmall)
                    else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(formatReading(reading),
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(width: 4),
                          Text(displayUnitFor(type),
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      Text(AppText.of(context).vitalsLastRecorded(
                              relativeDay(reading.timestamp, AppText.of(context))),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onAdd,
                tooltip: AppText.of(context).vitalsAddReading,
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
          _error = AppText.of(context).vitalsErrEnterNumber(
              vitalFieldLabel(AppText.of(context), type).toLowerCase()));
      return;
    }

    final range = displayPlausibleRange(type);
    if (primary < range.$1 || primary > range.$2) {
      setState(() => _error = AppText.of(context).vitalsErrOutOfRange(
          vitalLabel(AppText.of(context), type).toLowerCase(),
          range.$1.toStringAsFixed(0),
          range.$2.toStringAsFixed(0),
          displayUnitFor(type)));
      return;
    }

    double? secondary;
    if (type.hasSecondary) {
      secondary = double.tryParse(_secondary.text.trim());
      if (secondary == null) {
        setState(() => _error = AppText.of(context).vitalsErrNeedLower);
        return;
      }
      final sRange = type.secondaryPlausibleRange;
      if (secondary < sRange.$1 || secondary > sRange.$2) {
        setState(() => _error = AppText.of(context).vitalsErrLowerRange);
        return;
      }
      if (secondary >= primary) {
        setState(() => _error = AppText.of(context).vitalsErrLowerHigher);
        return;
      }
    }

    setState(() => _saving = true);
    await _service.add(VitalReading(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      timestamp: _timestamp,
      value: toCanonicalValue(type, primary),
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
            Text(vitalLabel(AppText.of(context), type),
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(AppText.of(context).vitalsMeasuredIn(displayUnitFor(type)),
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
                    decoration: InputDecoration(
                        labelText: vitalFieldLabel(AppText.of(context), type)),
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
                          labelText: AppText.of(context).vitalBpLower),
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
                        AppText.of(context).vitalsRecordedOn(
                            relativeDay(_when, AppText.of(context)).toLowerCase()),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Text(AppText.of(context).vitalsChangeDate,
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
              decoration: InputDecoration(
                labelText: AppText.of(context).vitalsNoteLabel,
                hintText: AppText.of(context).vitalsNoteHint,
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
                child: Text(AppText.of(context).vitalsSaveReading),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Lets the user pick the units they think in.
///
/// Changing a unit converts what is DISPLAYED. Stored readings stay in
/// their canonical form, so switching back and forth never degrades a
/// value through repeated rounding.
class _UnitsSheet extends StatefulWidget {
  const _UnitsSheet();

  @override
  State<_UnitsSheet> createState() => _UnitsSheetState();
}

class _UnitsSheetState extends State<_UnitsSheet> {
  bool _changed = false;

  @override
  Widget build(BuildContext context) {
    final prefs = UnitPrefs();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(AppText.of(context).unitsTitle,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            AppText.of(context).unitsDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text(AppText.of(context).settingsTemperature,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TemperatureUnit.values
                .map((unit) => ChoiceChip(
                      label: Text(unit == TemperatureUnit.celsius
                          ? "\u00B0C"
                          : "\u00B0F"),
                      selected: prefs.temperature == unit,
                      onSelected: (_) async {
                        await prefs.setTemperature(unit);
                        if (mounted) setState(() => _changed = true);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          Text(AppText.of(context).settingsWeight,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: WeightUnit.values
                .map((unit) => ChoiceChip(
                      label: Text(unit == WeightUnit.lb ? "lb" : "kg"),
                      selected: prefs.weight == unit,
                      onSelected: (_) async {
                        await prefs.setWeight(unit);
                        if (mounted) setState(() => _changed = true);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _changed),
              child: Text(AppText.of(context).actionDone),
            ),
          ),
        ],
      ),
    );
  }
}
