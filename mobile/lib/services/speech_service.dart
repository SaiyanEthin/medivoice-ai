import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

/// Wraps microphone capture + on-device Whisper transcription.
///
/// Deliberately isolated from the consultation pipeline: this service only
/// turns speech into a plain String. Everything downstream (symptom matching,
/// prediction, advice) already operates on plain text, so nothing else in the
/// app needs to know whether that text came from a keyboard or a microphone.
///
/// NOTE: whisper_ggml's transcribe() does NOT auto-download the model.
/// downloadModel() must be called explicitly first. This class calls it once
/// and caches the result in memory for the lifetime of the service. The
/// FIRST call needs internet (~75MB for tiny). Bundling ggml-tiny.bin as an
/// app asset (for true airplane-mode operation) is a separate, later
/// milestone.
class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  final WhisperController _whisper = WhisperController();

  bool _isRecording = false;
  String? _recordingPath;
  bool _modelReady = false;

  bool get isRecording => _isRecording;
  bool get isModelReady => _modelReady;

  /// Requests microphone permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Downloads (or confirms cached) the Whisper model. Safe to call
  /// repeatedly - it's a no-op after the first successful call.
  ///
  /// NOTE: whisper_ggml's downloadModel() does not expose a progress
  /// callback - it's just an awaitable Future that completes when the
  /// ~75MB tiny model is on disk. The caller should show an indeterminate
  /// "downloading model, first run only" spinner rather than a percentage.
  Future<void> ensureModelReady() async {
    if (_modelReady) return;
    await _whisper.downloadModel(WhisperModel.tiny);
    _modelReady = true;
  }

  /// Starts recording to a 16 kHz mono WAV file - the format Whisper expects.
  /// Returns false if permission was denied or recording could not start.
  Future<bool> startRecording() async {
    if (_isRecording) return false;

    if (!await requestPermission()) return false;
    if (!await _recorder.hasPermission()) return false;

    final dir = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}/medivoice_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _recordingPath!,
    );

    _isRecording = true;
    return true;
  }

  /// Stops recording and transcribes with Whisper.
  ///
  /// [languageCode] should be 'en', 'hi', 'kn', or 'auto'.
  /// Returns a [TranscriptionResult] with the text and timing information,
  /// or null if nothing was recorded. On the very first call this will
  /// pause for the model download (no progress reporting available -
  /// see [ensureModelReady]).
  Future<TranscriptionResult?> stopAndTranscribe({
    String languageCode = 'auto',
  }) async {
    if (!_isRecording) return null;

    await _recorder.stop();
    _isRecording = false;

    final path = _recordingPath;
    if (path == null) return null;

    final file = File(path);
    if (!await file.exists()) return null;
    final fileSizeBytes = await file.length();

    // Make sure the model is actually on disk before we ask whisper_ggml
    // to load it - this is the step that was missing before.
    await ensureModelReady();

    final stopwatch = Stopwatch()..start();
    final result = await _whisper.transcribe(
      model: WhisperModel.tiny, // multilingual tiny
      audioPath: path,
      lang: languageCode,
    );
    stopwatch.stop();

    return TranscriptionResult(
      text: result?.transcription.text.trim() ?? '',
      inferenceMs: stopwatch.elapsedMilliseconds,
      audioFileBytes: fileSizeBytes,
      languageRequested: languageCode,
    );
  }

  /// Cancels an in-progress recording without transcribing.
  Future<void> cancelRecording() async {
    if (!_isRecording) return;
    await _recorder.stop();
    _isRecording = false;
    _recordingPath = null;
  }

  /// Frees the Whisper model from native memory. Call this when a
  /// consultation ends - on a 4GB device we should not keep ~100MB of
  /// model weights resident indefinitely.
  Future<void> releaseModel() async {
    await _whisper.releaseModel();
    _modelReady = false;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

class TranscriptionResult {
  final String text;
  final int inferenceMs;
  final int audioFileBytes;
  final String languageRequested;

  TranscriptionResult({
    required this.text,
    required this.inferenceMs,
    required this.audioFileBytes,
    required this.languageRequested,
  });

  bool get isEmpty => text.isEmpty;
}
