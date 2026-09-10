import 'package:flutter/material.dart';
import '../core/text_scale_prefs.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Text size, with a live preview.
///
/// The preview matters: choosing "Larger" from a list tells you nothing
/// about whether the result is actually readable to you.
class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  State<DisplaySettingsScreen> createState() =>
      _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  final _prefs = TextScalePrefs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Text size")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(AppText.of(context).displayHeading,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              AppText.of(context).displaySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            ...TextSizeOption.values.map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionTile(
                    option: option,
                    selected: _prefs.value == option,
                    onTap: () async {
                      await _prefs.set(option);
                      if (mounted) setState(() {});
                    },
                  ),
                )),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppText.of(context).displayPreviewLabel,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Text(AppText.of(context).displayPreviewQuestion,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    Text(
                      AppText.of(context).displayPreviewResult,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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

class _OptionTile extends StatelessWidget {
  final TextSizeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(option.label,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
