import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/language_prefs_service.dart';
import 'how_it_works_screen.dart';
import 'language_select_screen.dart';
import 'voice_input_screen.dart';

/// Landing screen. Introduces the app and starts a new consultation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// First-ever "Start Consultation" tap routes through the one-time
  /// language picker. Every tap after that goes straight to the voice
  /// input screen, which already knows the saved preference.
  Future<void> _startConsultation(BuildContext context) async {
    final hasPreference = await LanguagePrefsService().hasPreference();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => hasPreference
            ? const VoiceInputScreen()
            : const LanguageSelectScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StartCard(onStart: () => _startConsultation(context)),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(
                        child: _FeatureTile(
                          icon: Icons.wifi_off_rounded,
                          title: "Works offline",
                          body: "No internet needed",
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureTile(
                          icon: Icons.lock_outline_rounded,
                          title: "Stays private",
                          body: "Nothing leaves your phone",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HowItWorksScreen()),
                    ),
                    icon: const Icon(Icons.help_outline_rounded, size: 18),
                    label: const Text("How MediVoice works"),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "MediVoice offers preliminary health awareness only. "
                    "It is not a diagnosis and does not replace a doctor.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 34,
        bottom: 34,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.health_and_safety_rounded,
                size: 32, color: Colors.white),
          ),
          const SizedBox(height: 18),
          const Text(
            "MediVoice AI",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Your offline health companion",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  final VoidCallback onStart;
  const _StartCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("How are you feeling today?",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              "Tell me what's wrong in your own words - speak or type, "
              "whichever is easier.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.mic_rounded),
                label: const Text("Start consultation"),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LanguageChip(label: "\u0c95\u0ca8\u0ccd\u0ca8\u0ca1"),
                SizedBox(width: 8),
                _LanguageChip(label: "\u0939\u093f\u0902\u0926\u0940"),
                SizedBox(width: 8),
                _LanguageChip(label: "English"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryDark, size: 22),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  const _LanguageChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
