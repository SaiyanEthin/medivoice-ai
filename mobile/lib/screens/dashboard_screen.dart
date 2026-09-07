import 'package:flutter/material.dart';
import '../core/date_format.dart';
import '../core/disease_display.dart';
import '../core/theme/app_theme.dart';
import '../core/unit_prefs.dart';
import '../models/consultation_record.dart';
import '../models/health_profile.dart';
import '../models/vital_reading.dart';
import '../services/consultation_history_service.dart';
import '../services/health_profile_service.dart';
import '../services/vitals_service.dart';
import 'health_profile_screen.dart';
import 'history_screen.dart';
import 'trends_screen.dart';
import 'vitals_screen.dart';

/// An overview of everything the app knows about the user.
///
/// Deliberately read-only: it reads the same local stores the rest of the
/// app writes to, and every action here navigates to the screen that owns
/// that data rather than editing in place.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _profileService = HealthProfileService();
  final _vitalsService = VitalsService();
  final _historyService = ConsultationHistoryService();

  HealthProfile? _profile;
  Map<VitalType, VitalReading?> _vitals = {};
  List<ConsultationRecord> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _profileService.load();
    final vitals = await _vitalsService.latestOfEach();
    final history = await _historyService.load();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _vitals = vitals;
      _recent = history.take(3).toList();
      _loading = false;
    });
  }

  Future<void> _go(Widget screen) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health dashboard")),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    _GreetingCard(profile: _profile),
                    const SizedBox(height: 22),
                    _SectionHeader(
                      title: "Latest vitals",
                      actionLabel: "View all",
                      onAction: () => _go(const VitalsScreen()),
                    ),
                    const SizedBox(height: 10),
                    _VitalsGrid(
                      vitals: _vitals,
                      onTap: () => _go(const VitalsScreen()),
                    ),
                    const SizedBox(height: 22),
                    _SectionHeader(
                      title: "Recent assessments",
                      actionLabel: _recent.isEmpty ? null : "View all",
                      onAction: () => _go(const HistoryScreen()),
                    ),
                    const SizedBox(height: 10),
                    if (_recent.isEmpty)
                      const _EmptyCard(
                        icon: Icons.history_rounded,
                        title: "No assessments yet",
                        body: "Start a consultation and the result will "
                            "appear here.",
                      )
                    else
                      ..._recent.map((record) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AssessmentRow(
                              record: record,
                              onTap: () => _go(const HistoryScreen()),
                            ),
                          )),
                    const SizedBox(height: 22),
                    _SectionHeader(
                      title: "Your profile",
                      actionLabel: _profile == null ? null : "Edit",
                      onAction: () => _go(const HealthProfileScreen()),
                    ),
                    const SizedBox(height: 10),
                    _ProfileCard(
                      profile: _profile,
                      onSetUp: () => _go(const HealthProfileScreen()),
                    ),
                    const SizedBox(height: 26),
                    Text("Quick actions",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _go(const VitalsScreen()),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text("Add a vital reading"),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _go(const TrendsScreen()),
                      icon: const Icon(Icons.show_chart_rounded, size: 18),
                      label: const Text("View health trends"),
                    ),                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _go(const HistoryScreen()),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text("View past assessments"),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _go(const HealthProfileScreen()),
                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                      label: const Text("Edit your profile"),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      "Everything shown here is stored on this phone only.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final HealthProfile? profile;
  const _GreetingCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile?.greetingName ?? '';
    final greeting = greetingForHour(DateTime.now().hour);
    final details = <String>[];
    if (profile?.age != null) details.add('${profile!.age} years old');
    final conditions = profile?.conditions.length ?? 0;
    final allergies = profile?.allergies.length ?? 0;
    if (conditions > 0) {
      details.add('$conditions condition${conditions == 1 ? '' : 's'}');
    }
    if (allergies > 0) {
      details.add('$allergies allerg${allergies == 1 ? 'y' : 'ies'}');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? greeting : '$greeting, $name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            details.isEmpty
                ? "Here's your health overview."
                : details.join('  \u00B7  '),
            style: TextStyle(
                fontSize: 14, color: Colors.white.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  final Map<VitalType, VitalReading?> vitals;
  final VoidCallback onTap;

  const _VitalsGrid({required this.vitals, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final types = VitalType.values;
    final anyRecorded = vitals.values.any((r) => r != null);
    final rows = <Widget>[];

    for (var i = 0; i < types.length; i += 2) {
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: _VitalTile(
                    type: types[i], reading: vitals[types[i]], onTap: onTap)),
            const SizedBox(width: 12),
            if (i + 1 < types.length)
              Expanded(
                  child: _VitalTile(
                      type: types[i + 1],
                      reading: vitals[types[i + 1]],
                      onTap: onTap))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ));
      if (i + 2 < types.length) rows.add(const SizedBox(height: 12));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!anyRecorded) ...[
          Text(
            "Add your first reading to start building a record.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
        ],
        ...rows,
      ],
    );
  }
}

class _VitalTile extends StatelessWidget {
  final VitalType type;
  final VitalReading? reading;
  final VoidCallback onTap;

  const _VitalTile(
      {required this.type, required this.reading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = reading;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconFor(type), size: 20, color: AppTheme.primaryDark),
            const SizedBox(height: 8),
            Text(type.label,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            if (r == null)
              Text("Tap to add",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.primaryDark))
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(formatReading(r),
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 3),
                  Text(displayUnitFor(type),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Text(relativeDay(r.timestamp),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssessmentRow extends StatelessWidget {
  final ConsultationRecord record;
  final VoidCallback onTap;

  const _AssessmentRow({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.isUncertain
                          ? "Symptoms unclear"
                          : diseaseDisplayName(record.disease ?? ''),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.isUncertain
                          ? relativeDay(record.timestamp)
                          : "${((record.confidence ?? 0) * 100).toStringAsFixed(1)}%"
                              "  \u00B7  ${relativeDay(record.timestamp)}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final HealthProfile? profile;
  final VoidCallback onSetUp;

  const _ProfileCard({required this.profile, required this.onSetUp});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    if (p == null) {
      return _EmptyCard(
        icon: Icons.person_add_alt_1_outlined,
        title: "No profile yet",
        body: "Add your details so MediVoice can keep your health "
            "information in one place.",
        actionLabel: "Set up profile",
        onAction: onSetUp,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelled(context, "Existing conditions", p.conditions),
            const SizedBox(height: 14),
            _labelled(context, "Allergies", p.allergies),
          ],
        ),
      ),
    );
  }

  Widget _labelled(BuildContext context, String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Text("None recorded",
              style: Theme.of(context).textTheme.bodyMedium)
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map((item) => Chip(
                      label: Text(item),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: AppTheme.primary),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
