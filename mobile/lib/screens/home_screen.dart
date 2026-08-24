import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/language_prefs_service.dart';
import 'language_select_screen.dart';
import 'placeholder_screen.dart';
import 'voice_input_screen.dart';
import 'speech_test_screen.dart';

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
        builder: (_) =>
            hasPreference ? const VoiceInputScreen() : const LanguageSelectScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // App icon placeholder
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      size: 52,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "MediVoice AI",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Your offline health assistant.\nSpeak your symptoms in Kannada, Hindi, or English.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 48),

                // Language availability row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _LanguageChip(label: "English"),
                    SizedBox(width: 10),
                    _LanguageChip(label: "हिंदी"),
                    SizedBox(width: 10),
                    _LanguageChip(label: "ಕನ್ನಡ"),
                  ],
                ),

                const SizedBox(height: 48),

                ElevatedButton.icon(
                  onPressed: () => _startConsultation(context),
                  icon: const Icon(Icons.mic_rounded),
                  label: const Text("Start Consultation"),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlaceholderScreen(title: "About"),
                      ),
                    );
                  },
                  child: const Text("About MediVoice AI"),
                ),

                // TEMPORARY: debug-only entry point for the Whisper validation
                // test. Remove once speech input is wired into the real flow.
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SpeechTestScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.science_outlined, size: 18),
                    label: const Text("[DEBUG] Whisper Test"),
                  ),
                ],

                const SizedBox(height: 40),

                Text(
                  "Works fully offline. Your symptoms are never sent to the internet.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
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
      backgroundColor: AppTheme.primary.withOpacity(0.08),
      labelStyle: const TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w500),
      side: BorderSide.none,
    );
  }
}
