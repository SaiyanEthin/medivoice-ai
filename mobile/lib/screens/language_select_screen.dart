import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/language_prefs_service.dart';
import 'voice_input_screen.dart';

/// Shown once - the first time a user taps "Start Consultation" and no
/// language preference is saved yet. Sets the language they'll speak in
/// by default; they can still switch per-recording on the voice input
/// screen itself, and this choice is never asked again.
class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  final _prefsService = LanguagePrefsService();
  bool _saving = false;

  Future<void> _selectAndContinue(String code) async {
    setState(() => _saving = true);
    await _prefsService.setPreferredLanguage(code);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VoiceInputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Your Language")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.translate_rounded, size: 56, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(
                "Which language would you like to speak in?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "You can switch languages anytime during a consultation.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (_saving)
                const Center(child: CircularProgressIndicator())
              else ...[
                _LanguageOptionButton(
                  label: "ಕನ್ನಡ",
                  sublabel: "Kannada",
                  onTap: () => _selectAndContinue('kn'),
                ),
                const SizedBox(height: 12),
                _LanguageOptionButton(
                  label: "हिंदी",
                  sublabel: "Hindi",
                  onTap: () => _selectAndContinue('hi'),
                ),
                const SizedBox(height: 12),
                _LanguageOptionButton(
                  label: "English",
                  sublabel: "English",
                  onTap: () => _selectAndContinue('en'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _LanguageOptionButton({
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        side: const BorderSide(color: AppTheme.primary),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          if (sublabel != label) ...[
            const SizedBox(height: 2),
            Text(sublabel, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ],
      ),
    );
  }
}
