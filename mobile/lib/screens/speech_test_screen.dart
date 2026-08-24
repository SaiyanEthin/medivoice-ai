import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../services/speech_service.dart';
import '../services/symptom_matcher_service.dart';

/// ISOLATED TEST HARNESS - not part of the consultation flow.
///
/// Purpose: measure whether Whisper-Tiny can transcribe our ~35 known symptom
/// phrases well enough in English, Hindi and Kannada to be usable. It records,
/// transcribes, shows the raw text, and runs it through the EXISTING symptom
/// matcher so we can see whether the transcription actually maps to symptom IDs.
///
/// This screen exists to produce evidence for a go/no-go decision. It does not
/// touch ConsultationProvider, the prediction pipeline, or any other screen.
class SpeechTestScreen extends StatefulWidget {
  const SpeechTestScreen({super.key});

  @override
  State<SpeechTestScreen> createState() => _SpeechTestScreenState();
}

class _SpeechTestScreenState extends State<SpeechTestScreen> {
  final SpeechService _speech = SpeechService();
  final SymptomMatcherService _matcher = SymptomMatcherService();

  String _language = 'kn'; // start on the language that matters most
  bool _busy = false;
  String _status = 'Ready.';
  final List<_TestRun> _runs = [];

  @override
  void initState() {
    super.initState();
    _matcher.initialize();
  }

  @override
  void dispose() {
    _speech.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_speech.isRecording) {
      setState(() {
        _busy = true;
        _status = 'Transcribing... (first run downloads the model, be patient)';
      });

      final result = await _speech.stopAndTranscribe(languageCode: _language);

      if (!mounted) return;

      if (result == null || result.isEmpty) {
        setState(() {
          _busy = false;
          _status = 'No speech recognized. Try again, closer to the mic.';
        });
        return;
      }

      List<String> present = [];
      List<String> denied = [];
      try {
        final analysis = _matcher.analyze(result.text);
        present = analysis.present;
        denied = analysis.denied;
      } catch (_) {
        // matcher not ready - leave lists empty
      }

      setState(() {
        _busy = false;
        _status = 'Done.';
        _runs.insert(
          0,
          _TestRun(
            language: result.languageRequested,
            text: result.text,
            inferenceMs: result.inferenceMs,
            audioBytes: result.audioFileBytes,
            matchedPresent: present,
            matchedDenied: denied,
          ),
        );
      });
    } else {
      final started = await _speech.startRecording();
      if (!mounted) return;
      setState(() {
        _status = started
            ? 'Recording... speak now, then tap Stop.'
            : 'Could not start recording - microphone permission denied?';
      });
    }
  }

  void _copyResults() {
    final buffer = StringBuffer();
    buffer.writeln('MediVoice AI - Whisper-Tiny test results');
    buffer.writeln('Device: Realme Narzo 50');
    buffer.writeln('');
    for (final run in _runs.reversed) {
      buffer.writeln('[${run.language}] "${run.text}"');
      buffer.writeln('   inference: ${run.inferenceMs} ms | '
          'audio: ${(run.audioBytes / 1024).toStringAsFixed(0)} KB');
      buffer.writeln('   matched present: ${run.matchedPresent}');
      buffer.writeln('   matched denied : ${run.matchedDenied}');
      buffer.writeln('');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisper Test'),
        actions: [
          if (_runs.isNotEmpty)
            IconButton(
              onPressed: _copyResults,
              icon: const Icon(Icons.copy_all_rounded),
              tooltip: 'Copy all results',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Language', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'kn', label: Text('ಕನ್ನಡ')),
                      ButtonSegment(value: 'hi', label: Text('हिंदी')),
                      ButtonSegment(value: 'en', label: Text('English')),
                      ButtonSegment(value: 'auto', label: Text('Auto')),
                    ],
                    selected: {_language},
                    onSelectionChanged: _busy
                        ? null
                        : (s) => setState(() => _language = s.first),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _busy ? null : _toggleRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _speech.isRecording ? AppTheme.danger : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    icon: Icon(_speech.isRecording
                        ? Icons.stop_rounded
                        : Icons.mic_rounded),
                    label: Text(_speech.isRecording ? 'Stop' : 'Record'),
                  ),
                  const SizedBox(height: 10),
                  Text(_status,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  if (_busy) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _runs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Try Kannada symptom phrases, e.g.\n\n'
                          '"ನನಗೆ ಜ್ವರ ಇದೆ"\n'
                          '"ತಲೆನೋವು ಮತ್ತು ಕೆಮ್ಮು ಇದೆ"\n'
                          '"ಹೊಟ್ಟೆ ನೋವು ಮತ್ತು ವಾಂತಿ"\n',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _runs.length,
                      itemBuilder: (_, i) => _RunCard(run: _runs[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestRun {
  final String language;
  final String text;
  final int inferenceMs;
  final int audioBytes;
  final List<String> matchedPresent;
  final List<String> matchedDenied;

  _TestRun({
    required this.language,
    required this.text,
    required this.inferenceMs,
    required this.audioBytes,
    required this.matchedPresent,
    required this.matchedDenied,
  });

  bool get matchedAnything => matchedPresent.isNotEmpty || matchedDenied.isNotEmpty;
}

class _RunCard extends StatelessWidget {
  final _TestRun run;
  const _RunCard({required this.run});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(run.language,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark)),
                ),
                const Spacer(),
                Text('${run.inferenceMs} ms',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 10),
            Text('Transcription',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            SelectableText(run.text,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  run.matchedAnything
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined,
                  size: 18,
                  color: run.matchedAnything
                      ? AppTheme.success
                      : AppTheme.danger,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    run.matchedAnything
                        ? 'Matched: ${run.matchedPresent.join(", ")}'
                            '${run.matchedDenied.isNotEmpty ? "  |  denied: ${run.matchedDenied.join(", ")}" : ""}'
                        : 'No symptom IDs matched',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
