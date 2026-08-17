import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'placeholder_screen.dart';
import 'voice_input_screen.dart';

/// Landing screen. Introduces the app and starts a new consultation.
/// Only THIS screen is "done" this milestone - Voice Input etc. are stubs.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoiceInputScreen(),
                    ),
                  );
                },
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

              const Spacer(),

              Text(
                "Works fully offline. Your symptoms are never sent to the internet.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
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
