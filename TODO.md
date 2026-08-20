# MediVoice AI — TODO

## Next milestone
**Whisper-Tiny integration** — replace the text field in
`mobile/lib/screens/voice_input_screen.dart` (`_buildInputArea`) with
mic capture + on-device transcription. The matcher and everything
downstream already operate on plain text, so nothing else should change.

Open questions to resolve first:
- Which Whisper binding for Flutter/Android? (whisper.cpp via FFI is the
  usual route; needs evaluation)
- Model bundling: ~75MB asset in the APK, or download-on-first-run?
- Web has no Whisper path — testing will require moving to an Android
  emulator or device. **The app has never been built for Android.**

## After Whisper
- [ ] First Android build (never attempted — expect setup friction)
- [ ] Offline LR migration: port weight-matrix math to Dart, swap inside
      `ConsultationRepository`, retire the HTTP dependency
- [ ] Offline advice: bundle `advice_templates.json` as a Flutter asset
- [ ] Offline directory: bundle SQLite via `sqflite`
- [ ] Airplane-mode acceptance test (the real definition of "done")

## Known issues (non-blocking)
- [ ] Home Screen claims "works fully offline" — untrue today. Either soften
      the copy or leave until offline migration lands.
- [ ] Brief spinner flash on Voice Input Screen while navigating to results
- [ ] Disclaimer card background reads muddy (accent @ 10% over grey)
- [ ] sklearn `InconsistentVersionWarning` — model pickled on 1.8.0, env has
      1.9.0. Harmless; retrain or pin to silence.
- [ ] README "Known limitation" / "Next milestones" sections are stale
- [ ] Sample phone numbers look like real Indian mobile numbers — mask before
      any public demo

## Model improvement (deferred, but increasingly necessary)
- [ ] Address the common-cold failure (see PROJECT_STATE.md limitation #2).
      Options: add mild/self-limiting class, augment training data with
      partial symptom subsets, or reweight. Requires retraining.
- [ ] Native-speaker verification of Kannada/Hindi symptom phrases
- [ ] Measure and record: precision, recall, F1, confusion matrix, inference
      time, model size, memory — needed for the paper
- [ ] Track how often real inputs land on "Symptoms Unclear". If it dominates,
      the app is safe but not useful, which changes the paper's framing.

## Production readiness (before any Play Store consideration)
- [ ] Replace synthetic directory with verified data (see DATA_SOURCES.md)
- [ ] Privacy policy + data handling statement
- [ ] Microphone permission rationale
- [ ] Confirm no network calls in the core pipeline
- [ ] Store metadata and medical disclaimers
