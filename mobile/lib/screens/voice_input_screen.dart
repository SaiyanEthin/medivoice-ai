import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/consultation_provider.dart';
import '../services/language_prefs_service.dart';
import '../services/speech_service.dart';
import '../services/symptom_matcher_service.dart';
import '../widgets/follow_up_question_card.dart';
import 'prediction_result_screen.dart';

/// Real voice input, wired to SpeechService (Whisper-Tiny, on-device).
///
/// Transcribed text lands in the SAME TextField used for typed input, so
/// _handleSubmit/matching/prediction below are completely unaware of
/// whether the text came from a keyboard or a microphone - exactly the
/// seam this screen was designed around from the start. The field stays
/// editable so a mistranscription can be corrected by hand rather than
/// forcing a re-record.
class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final SymptomMatcherService _matcher = SymptomMatcherService();
  final SpeechService _speech = SpeechService();
  final LanguagePrefsService _prefsService = LanguagePrefsService();

  bool _matcherReady = false;
  String? _noMatchWarning;

  String _selectedLanguage = 'en'; // overwritten once the saved preference loads
  bool _isRecording = false;
  bool _isTranscribing = false;

  static const _languages = [
    {'code': 'kn', 'label': 'ಕನ್ನಡ'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'en', 'label': 'English'},
    {'code': 'auto', 'label': 'Auto'},
  ];

  @override
  void initState() {
    super.initState();
    _matcher.initialize().then((_) {
      if (mounted) setState(() => _matcherReady = true);
    });
    _loadPreferredLanguage();
  }

  Future<void> _loadPreferredLanguage() async {
    final saved = await _prefsService.getPreferredLanguage();
    if (mounted && saved != null) {
      setState(() => _selectedLanguage = saved);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Fire-and-forget: free the ~100MB model from native memory once this
    // screen goes away. Not awaited because dispose() can't be async.
    _speech.releaseModel();
    _speech.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (!_matcherReady) return;

    final analysis = _matcher.analyze(_controller.text);

    if (analysis.isEmpty) {
      setState(() {
        _noMatchWarning =
            "Couldn't recognize any symptoms in that text. Try describing them more simply, e.g. \"fever and cough\".";
      });
      return;
    }

    if (analysis.present.isEmpty) {
      setState(() {
        _noMatchWarning =
            "You mentioned what you don't have, but not what you do. Please describe your symptoms.";
      });
      return;
    }

    setState(() => _noMatchWarning = null);
    context.read<ConsultationProvider>().submitInitialSymptoms(
          analysis.present,
          initialDenied: analysis.denied,
        );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _isTranscribing = true;
      });

      try {
        final result = await _speech.stopAndTranscribe(
          languageCode: _selectedLanguage,
        );

        if (!mounted) return;

        if (result != null && !result.isEmpty) {
          setState(() {
            // Overwrites rather than appends - each new recording replaces
            // whatever was there before, so the field always shows exactly
            // what was just said (still editable by hand afterward).
            _controller.text = result.text;
            _noMatchWarning = null;
          });
        } else {
          setState(() {
            _noMatchWarning =
                "Didn't catch that. Please try recording again, speaking clearly.";
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _noMatchWarning = "Something went wrong during transcription. Please try again.";
        });
      } finally {
        if (mounted) setState(() => _isTranscribing = false);
      }
    } else {
      final started = await _speech.startRecording();
      if (!mounted) return;
      if (started) {
        setState(() => _isRecording = true);
      } else {
        setState(() {
          _noMatchWarning =
              "Microphone permission is needed to record. Please allow it in your phone's settings.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Describe Your Symptoms")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Describe Your Symptoms", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      _buildLanguageSelector(),
                      const SizedBox(height: 16),
                      _buildInputArea(),
                      const SizedBox(height: 10),
                      Text(
                        "Examples: \"fever and cough\" · \"headache, nausea\" · \"pet dard, ulti\"",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_noMatchWarning != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _noMatchWarning!,
                          style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _matcherReady ? () => _handleSubmit(context) : null,
                        child: const Text("Predict"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _ConsultationStatusArea(),
            ],
          ),
        ),
      ),
    );
  }

  /// Pill row for picking the recording language. Defaults to the saved
  /// preference from LanguagePrefsService but can be overridden per
  /// recording without changing that saved default. Locked while a
  /// recording/transcription is in flight to avoid switching mid-take.
  Widget _buildLanguageSelector() {
    final locked = _isRecording || _isTranscribing;
    return Wrap(
      spacing: 8,
      children: _languages.map((lang) {
        final isSelected = _selectedLanguage == lang['code'];
        return ChoiceChip(
          label: Text(lang['label']!),
          selected: isSelected,
          onSelected: locked ? null : (_) => setState(() => _selectedLanguage = lang['code']!),
        );
      }).toList(),
    );
  }

  /// Mic button + editable text field. Voice fills the field; the field
  /// stays editable so a user can correct a mistranscription, or type
  /// instead entirely (e.g. in a noisy room, or if the mic fails).
  Widget _buildInputArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isTranscribing ? null : _toggleRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? AppTheme.danger : AppTheme.primary,
            ),
            icon: _isTranscribing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
            label: Text(_isTranscribing ? "Transcribing..." : (_isRecording ? "Stop" : "Record")),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "First recording after install may take a bit longer while the offline speech model loads.",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "e.g. I have fever and a cough",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

/// Handles loading/error states and the follow-up question loop.
/// Once the provider has a FINAL result (no more follow-ups needed),
/// this auto-navigates to the real Prediction Screen - it never renders
/// a result itself, keeping that entirely out of this screen as required.
class _ConsultationStatusArea extends StatelessWidget {
  const _ConsultationStatusArea();

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultationProvider>(
      builder: (context, provider, _) {
        switch (provider.status) {
          case ConsultationStatus.idle:
            return const SizedBox.shrink();

          case ConsultationStatus.loading:
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );

          case ConsultationStatus.error:
            return Card(
              color: AppTheme.danger.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Error: ${provider.errorMessage}\n\nIs the backend running? Check http://127.0.0.1:8000/docs",
                  style: const TextStyle(color: AppTheme.danger),
                ),
              ),
            );

          case ConsultationStatus.success:
            final result = provider.result!;

            if (result.needsFollowup) {
              return FollowUpQuestionCard(questions: result.followUpQuestions);
            }

            // Final result ready - navigate to the real Prediction Screen.
            // Scheduled after the current build so it's safe to call
            // Navigator during a Consumer rebuild.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PredictionResultScreen()),
                );
              }
            });
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
