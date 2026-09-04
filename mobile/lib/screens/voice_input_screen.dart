import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/disease_display.dart';
import '../core/theme/app_theme.dart';
import '../models/chat_message.dart';
import '../providers/consultation_provider.dart';
import '../services/language_prefs_service.dart';
import '../services/selfcare_guidance_service.dart';
import '../services/speech_service.dart';
import '../services/symptom_matcher_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/follow_up_question_card.dart';
import 'prediction_result_screen.dart';

/// The consultation, presented as a message thread.
///
/// This is a VIEW change only. Symptom matching, prediction, the confidence
/// gates and the follow-up logic are untouched - ConsultationProvider is
/// still the single source of truth and this screen only renders what it
/// reports.
///
/// Voice and typing feed the same text path, so the pipeline below cannot
/// tell which was used.
class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final SymptomMatcherService _matcher = SymptomMatcherService();
  final SpeechService _speech = SpeechService();
  final LanguagePrefsService _prefsService = LanguagePrefsService();

  final List<ChatMessage> _messages = [];

  bool _matcherReady = false;
  String _selectedLanguage = 'en';
  bool _isRecording = false;
  bool _isTranscribing = false;

  ConsultationProvider? _provider;
  ConsultationStatus? _lastStatus;
  int _lastRound = -1;

  static const _languages = [
    {'code': 'kn', 'label': '\u0c95\u0ca8\u0ccd\u0ca8\u0ca1'},
    {'code': 'hi', 'label': '\u0939\u093f\u0902\u0926\u0940'},
    {'code': 'en', 'label': 'English'},
    {'code': 'auto', 'label': 'Auto'},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage.app(
        "Hello! Tell me how you're feeling - you can speak or type.\n\n"
        "For example: \"I have fever and a cough\"."));
    _matcher.initialize().then((_) {
      if (mounted) setState(() => _matcherReady = true);
    });
    // Warm up the guidance asset so the result screen can read it
    // synchronously. Fire-and-forget: it falls back to static text.
    SelfCareGuidanceService().initialize();
    _loadPreferredLanguage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<ConsultationProvider>();
    if (!identical(p, _provider)) {
      _provider?.removeListener(_onConsultationChanged);
      _provider = p;
      _provider!.addListener(_onConsultationChanged);
    }
  }

  Future<void> _loadPreferredLanguage() async {
    final saved = await _prefsService.getPreferredLanguage();
    if (mounted && saved != null) {
      setState(() => _selectedLanguage = saved);
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onConsultationChanged);
    _controller.dispose();
    _scroll.dispose();
    // Fire-and-forget: release the speech model from native memory.
    _speech.releaseModel();
    _speech.dispose();
    super.dispose();
  }

  /// Appends thread entries as the provider progresses. Guarded on
  /// (status, round) so a rebuild for any other reason doesn't duplicate a
  /// bubble.
  void _onConsultationChanged() {
    final p = _provider;
    if (p == null) return;
    if (p.status == _lastStatus && p.followUpRound == _lastRound) return;

    setState(() {
      switch (p.status) {
        case ConsultationStatus.idle:
          // reset() was called (Try Again) - start a fresh thread.
          _messages
            ..clear()
            ..add(ChatMessage.app(
                "Let's start again. How are you feeling?"));
          break;
        case ConsultationStatus.success:
          final r = p.result!;
          if (r.needsFollowup) {
            _messages.add(ChatMessage.questions(r.followUpQuestions));
          } else {
            _messages.add(ChatMessage.result(r));
          }
          break;
        case ConsultationStatus.error:
          _messages.add(ChatMessage.app(
              "Something went wrong working that out. Please try again."));
          break;
        case ConsultationStatus.loading:
          break;
      }
      _lastStatus = p.status;
      _lastRound = p.followUpRound;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    if (!_matcherReady) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final analysis = _matcher.analyze(text);

    setState(() {
      _messages.add(ChatMessage.user(text));
      _controller.clear();
    });

    if (analysis.isEmpty) {
      setState(() => _messages.add(ChatMessage.app(
          "I couldn't pick out any symptoms there. Try describing them "
          "more simply - for example \"fever and cough\".")));
      _scrollToBottom();
      return;
    }

    if (analysis.present.isEmpty) {
      setState(() => _messages.add(ChatMessage.app(
          "You told me what you don't have, but not what you do. "
          "What symptoms are you experiencing?")));
      _scrollToBottom();
      return;
    }

    _scrollToBottom();
    _provider!.submitInitialSymptoms(
      analysis.present,
      initialDenied: analysis.denied,
    );
  }

  void _submitAnswers(ChatMessage message, Map<String, bool> answers) {
    setState(() => message.submittedAnswers = answers);
    _provider!.answerFollowUpBatch(answers);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _isTranscribing = true;
      });
      try {
        final result =
            await _speech.stopAndTranscribe(languageCode: _selectedLanguage);
        if (!mounted) return;
        if (result != null && !result.isEmpty) {
          setState(() => _controller.text = result.text);
        } else {
          setState(() => _messages.add(ChatMessage.app(
              "I didn't catch that. Please try again, speaking clearly.")));
          _scrollToBottom();
        }
      } catch (_) {
        if (!mounted) return;
        setState(() => _messages.add(ChatMessage.app(
            "Something went wrong while listening. Please try again.")));
        _scrollToBottom();
      } finally {
        if (mounted) setState(() => _isTranscribing = false);
      }
    } else {
      final started = await _speech.startRecording();
      if (!mounted) return;
      if (started) {
        setState(() => _isRecording = true);
      } else {
        setState(() => _messages.add(ChatMessage.app(
            "I need microphone permission to listen. You can allow it in "
            "your phone's settings, or type instead.")));
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<ConsultationProvider>().status;
    final isThinking = status == ConsultationStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F4),
      appBar: AppBar(
        title: const Text("MediVoice"),
        actions: [_buildLanguageMenu()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _messages.length + (isThinking ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length) return const TypingBubble();
                  return _buildMessage(_messages[i]);
                },
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageMenu() {
    final locked = _isRecording || _isTranscribing;
    final current = _languages
        .firstWhere((l) => l['code'] == _selectedLanguage)['label']!;
    return PopupMenuButton<String>(
      enabled: !locked,
      onSelected: (code) => setState(() => _selectedLanguage = code),
      itemBuilder: (_) => _languages
          .map((l) => PopupMenuItem(
                value: l['code'],
                child: Text(l['label']!),
              ))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.translate_rounded, size: 18),
            const SizedBox(width: 6),
            Text(current),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage m) {
    switch (m.kind) {
      case ChatKind.text:
        return ChatBubble(
          isUser: m.role == ChatRole.user,
          child: Text(m.text),
        );

      case ChatKind.questions:
        return ChatBubble(
          child: FollowUpQuestionCard(
            questions: m.questions,
            submittedAnswers: m.submittedAnswers,
            onSubmit: (answers) => _submitAnswers(m, answers),
          ),
        );

      case ChatKind.result:
        final r = m.result!;
        return ChatBubble(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (r.isUncertain) ...[
                Text("I'm not confident enough to suggest a specific "
                    "condition from what you've told me."),
                const SizedBox(height: 6),
                Text(
                  "That's common with mild or early illness. I can still "
                  "suggest some things that may help.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ] else ...[
                Text("This may be consistent with",
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  diseaseDisplayName(r.topPrediction.disease),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  "Model score: "
                  "${(r.topPrediction.confidence * 100).toStringAsFixed(1)}% "
                  "- a pattern match, not a diagnosis.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PredictionResultScreen()),
                  ),
                  icon: const Icon(Icons.article_outlined, size: 18),
                  label: Text(r.isUncertain
                      ? "See what you can do"
                      : "See full assessment"),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: _isTranscribing ? null : _toggleRecording,
            iconSize: 28,
            color: _isRecording ? AppTheme.danger : AppTheme.primary,
            icon: _isTranscribing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isRecording ? Icons.stop_circle : Icons.mic_rounded),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: _isRecording
                    ? "Listening..."
                    : (_isTranscribing ? "Transcribing..." : "Type or speak"),
                filled: true,
                fillColor: const Color(0xFFF2F5F4),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            onPressed: _matcherReady ? _send : null,
            icon: const Icon(Icons.send_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
