import 'package:flutter/material.dart';
import '../core/app_locale.dart';
import '../core/text_scale_prefs.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../core/unit_prefs.dart';
import '../services/health_data_service.dart';
import '../services/speech_output_service.dart';
import 'display_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _dataService = HealthDataService();
  final _voice = SpeechOutputService();

  List<String> _storedSummary = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final summary = await _dataService.summary();
    if (mounted) {
      setState(() {
        _storedSummary = summary;
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.of(context).settingsDeleteTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppText.of(context).settingsDeleteBody),
            const SizedBox(height: 8),
            ..._storedSummary.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text("\u2022  $item"),
                )),
            const SizedBox(height: 10),
            Text(AppText.of(context).settingsDeleteUndone),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppText.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: Text(AppText.of(context).actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _dataService.clearAll();
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppText.of(context).settingsDataDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = TextScalePrefs();
    final units = UnitPrefs();

    return Scaffold(
      appBar: AppBar(title: Text(AppText.of(context).settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            _Heading(AppText.of(context).settingsLanguage),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.of(context).settingsLanguageDesc,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in const [
                          ('en', 'English'),
                          ('kn', '\u0c95\u0ca8\u0ccd\u0ca8\u0ca1'),
                          ('hi', '\u0939\u093f\u0902\u0926\u0940'),
                        ])
                          ChoiceChip(
                            label: Text(option.$2),
                            selected: AppLocale().value.languageCode ==
                                option.$1,
                            onSelected: (_) async {
                              await AppLocale().set(option.$1);
                              // Rebuild the whole row, not just the chip
                              // that was tapped - otherwise the previously
                              // selected one keeps its highlight.
                              if (mounted) setState(() {});
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Kannada and Hindi are being translated. Anything not "
                      "yet translated stays in English, and symptom and "
                      "condition names are still shown in English.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _Heading(AppText.of(context).settingsDisplay),
            Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.format_size_rounded,
                    color: AppTheme.primaryDark),
                title: Text(AppText.of(context).settingsTextSize),
                subtitle: Text(textScale.value.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DisplaySettingsScreen()),
                  );
                  if (mounted) setState(() {});
                },
              ),
            ),
            const SizedBox(height: 22),
            _Heading(AppText.of(context).settingsMeasurements),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                selected: units.temperature == unit,
                                onSelected: (_) async {
                                  await units.setTemperature(unit);
                                  if (mounted) setState(() {});
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(AppText.of(context).settingsWeight,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: WeightUnit.values
                          .map((unit) => ChoiceChip(
                                label:
                                    Text(unit == WeightUnit.lb ? "lb" : "kg"),
                                selected: units.weight == unit,
                                onSelected: (_) async {
                                  await units.setWeight(unit);
                                  if (mounted) setState(() {});
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppText.of(context).settingsUnitsNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _Heading(AppText.of(context).settingsVoice),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    secondary: Icon(
                      _voice.enabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: AppTheme.primaryDark,
                    ),
                    title: Text(AppText.of(context).settingsVoiceGuidance),
                    subtitle: Text(AppText.of(context).settingsVoiceGuidanceSub),
                    value: _voice.enabled,
                    onChanged: (value) async {
                      await _voice.setEnabled(value);
                      if (mounted) setState(() {});
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      "Voice guidance follows the language above. Your "
                      "phone needs that language's voice data installed - "
                      "if it isn't, the app stays silent rather than "
                      "reading the wrong pronunciation.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _Heading(AppText.of(context).settingsYourData),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            size: 18, color: AppTheme.primaryDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppText.of(context).settingsDataNote,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_loading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_storedSummary.isEmpty)
                      Text(AppText.of(context).settingsNothingStored,
                          style: Theme.of(context).textTheme.bodySmall)
                    else ...[
                      Text(AppText.of(context).settingsCurrentlyStored,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      ..._storedSummary.map((item) => Text("\u2022  $item",
                          style: Theme.of(context).textTheme.bodyMedium)),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _confirmDelete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.danger,
                            side: const BorderSide(
                                color: AppTheme.danger, width: 1.2),
                          ),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18),
                          label: Text(AppText.of(context).settingsDeleteData),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
