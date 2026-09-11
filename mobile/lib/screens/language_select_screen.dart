import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/language_prefs_service.dart';
import 'voice_input_screen.dart';

/// Shown once - the first time a user taps "Start Consultation" and no
/// language preference is saved yet. Sets the language they'll speak in
/// by default; they can still switch per-recording on the voice input
/// screen itself, and this choice is never asked again.
class LanguageSelectScreen extends StatefulWidget {
  /// Passed straight through to VoiceInputScreen. On a first run the
  /// speak-now shortcut routes through here, and the intent to start
  /// recording shouldn't be lost on the way.
  final bool autoStartRecording;

  const LanguageSelectScreen({super.key, this.autoStartRecording = false});

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
      MaterialPageRoute(
        builder: (_) => VoiceInputScreen(
          autoStartRecording: widget.autoStartRecording,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your language \u00B7 \u0cad\u0cbe\u0cb7\u0cc6 \u0c86\u0cb0\u0cbf\u0cb8\u0cbf \u00B7 \u092d\u093e\u0937\u093e \u091a\u0941\u0928\u0947\u0902')),
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
                'Which language would you like to speak in?\n\u0ca8\u0cbf\u0cae\u0ccd\u0cae \u0cad\u0cbe\u0cb7\u0cc6 \u0caf\u0cbe\u0cb5\u0cc1\u0ca6\u0cc1?\n\u0906\u092a \u0915\u094c\u0928 \u0938\u0940 \u092d\u093e\u0937\u093e \u092c\u094b\u0932\u0928\u093e \u091a\u093e\u0939\u0947\u0902\u0917\u0947?',
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
