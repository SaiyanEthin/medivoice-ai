import os
import sys

CONTENT = """# MediVoice AI - Handover

Written to hand this project to a fresh session. It maps the codebase,
records the decisions that aren't obvious from reading the code, and lists
what is deliberately absent.

The code itself is the source of truth. Files carry comments explaining
*why*, not just what.

---

## 1. What this is

An offline-first, voice-driven preliminary health assessment app for
Android. Final-year BE (AI&ML) capstone, VVIT Bengaluru.

**Pipeline:**

```
Voice (Kannada / Hindi / English) or typing
  -> Whisper-Tiny, on-device speech-to-text
  -> symptom matcher (free text -> symptom columns)
  -> Logistic Regression, ported to Dart
  -> confidence gates -> follow-up questions or result
  -> rule-based advice engine
  -> doctor recommendation
```

Everything after the one-time speech-model download runs offline.

**Important:** the rule-based advice engine does NOT identify the disease.
Logistic Regression does. The advice engine maps an already-predicted
disease to guidance. That ordering gets asked about.

---

## 2. Repository layout

```
medivoice-ai/
  mobile/          the Flutter app - this is the product
  backend/         FastAPI, RETIRED from the app, kept for reference
  ml/              datasets, training scripts, exported models
  docs/            EVALUATION.md, this file
```

`backend/` is no longer called by the app. It remains because the Dart
port was verified against it and the training pipeline lives alongside it.

---

## 3. The app, file by file

### Core (`mobile/lib/core/`)

| File | Purpose |
| --- | --- |
| `config.dart` | `AppConfig`: confidence threshold 0.65, 3 follow-up rounds, 3 questions each, minimum 3 symptoms. Mirrors `backend/config.py`. |
| `theme/app_theme.dart` | All colours, text scale, component styling. Changing this restyles every screen. |
| `date_format.dart` | `relativeDay`, `clockTime`, `shortDate`, `dayMonth`, `greetingForHour`. |
| `disease_display.dart` | `diseaseDisplayName()` - maps raw model labels to clean text. The dataset label for vertigo is misspelled and double-spaced; this fixes it at display time only. |
| `unit_prefs.dart` | Temperature and weight unit choice, plus conversions. |
| `text_scale_prefs.dart` | App-wide text size. A `ValueNotifier` so the root rebuilds on change. |

### Models (`mobile/lib/models/`)

`prediction_result.dart`, `advice.dart`, `doctor.dart`,
`chat_message.dart`, `consultation_record.dart`, `health_profile.dart`,
`vital_reading.dart`, `symptom_severity.dart`.

### Services (`mobile/lib/services/`)

| File | Purpose |
| --- | --- |
| `speech_service.dart` | Whisper-Tiny wrapper. Must call `ensureModelReady()` before `transcribe()` - `whisper_ggml` does NOT auto-download. |
| `symptom_matcher_service.dart` | Free text -> symptom columns. Handles negation, `match:false` entries, `_match_overrides`. |
| `disease_predictor_service.dart` | The Dart LR port. Softmax over class scores. `assetPath` selects which weights file. |
| `consultation_orchestrator_service.dart` | The two gates and follow-up question selection. |
| `advice_service_dart.dart` | Disease -> guidance, from a bundled JSON. |
| `doctor_service_dart.dart` | Disease -> specialists -> doctor records. |
| `selfcare_guidance_service.dart` | Symptom-group guidance for the uncertain case. |
| `speech_output_service.dart` | Voice output via device TTS. English only for now. |
| `health_profile_service.dart` | Name, age, sex, conditions, allergies. |
| `vitals_service.dart` | Dated readings for six vitals, capped per type. |
| `consultation_history_service.dart` | Past assessments, capped at 50. |
| `health_data_service.dart` | Summarises and deletes all stored health data. |
| `language_prefs_service.dart` | Preferred consultation language. |
| `api_service.dart` | LEGACY. No longer called. Kept for rollback reference. |

### Provider and repository

`consultation_provider.dart` holds one consultation's state: symptoms,
denied symptoms, severities, round counter, result.

`consultation_repository.dart` is the seam the whole architecture turns
on. Its public interface never changed when the app moved from HTTP to
on-device inference - only its internals did. Nothing above it needed
touching.

### Screens

Home, consultation (chat), result, advice, doctors, dashboard, profile,
history, vitals, vital history, trends, settings, text size, how it works,
language select.

### Assets (`mobile/assets/data/`)

| File | Notes |
| --- | --- |
| `symptom_dictionary.json` | 86 matchable symptoms in en/hi/kn, plus `_match_overrides`. |
| `lr_model_weights.json` | **The production model.** 10 classes, 57 symptoms. |
| `lr_model_weights_25class.json` | Candidate, NOT in use. See section 5. |
| `advice_templates.json` | Guidance for 25 diseases. |
| `doctors.json` | 15 SYNTHETIC doctors. Not real people. |
| `selfcare_guidance.json` | 7 symptom groups plus red flags. |

---

## 4. Decisions that aren't obvious from the code

These were all deliberate. Changing one without understanding why will
break something subtle.

**Denied symptoms encode as -1, not 0.** A "No" counts as evidence
*against* diseases associated with that symptom. It is not the same as
unanswered, which contributes nothing. Any change to follow-up controls
must preserve three distinct states: yes, no, unanswered.

**Severity is stored but never reaches the classifier.** The training data
is binary with no validated severity labels, so any numeric weighting
would be an assumption rather than something learned - and it would
invalidate every measurement in `EVALUATION.md`. A test asserts that
predictions are identical with and without severity. If it ever fails,
severity has leaked into the model.

**Some phrases map to several symptom columns.** "stomach pain" credits
`abdominal_pain`, `belly_pain` and `stomach_pain`. This helps recall but
means one utterance can satisfy the 3-symptom gate. Known trade-off. The
result chips de-duplicate by label so the user doesn't see one complaint
listed three times.

**`match:false` entries** supply a readable label for follow-up questions
without becoming free-text match targets. Used for background facts
(`family_history`), third-person observations (`toxic_look_(typhos)`), and
things nobody says aloud (`internal_itching`).

**`_match_overrides`** suppresses specific substring false positives -
"rash" firing inside "gale mein kharash", "vomiting" inside "feeling like
vomiting". Deliberately an explicit list rather than a general
longest-match rule, which would also stop "coughing up blood" crediting
cough.

**Follow-up rounds are answered as a batch.** Each button used to submit
immediately, which advanced the round after one answer and discarded the
rest - so the real budget was 1 question per round, not 3. Fixed with
batch submission and regression tests.

**Vital storage is canonical**: °F and kg regardless of display
preference. Storing in the display unit would mean rewriting every past
reading when the preference changed.

**Vitals validation is plausibility only.** It rejects a pulse of 9999. It
never labels a reading normal or abnormal - that is clinical
interpretation, and the app does not do it. The trend chart draws no
reference bands for the same reason.

**The chat does not auto-navigate to the result.** Being thrown to another
screen mid-conversation breaks the metaphor, so the result arrives as a
bubble with a button.

**Voice output is English only.** All spoken content - question templates,
disease names, guidance - exists only in English. A Kannada voice reading
English words produces phonetic nonsense, which is worse than English and
worse than silence. `speak()` already takes a locale for when this changes.

---

## 5. The 25-class experiment - built, measured, rejected

Expanding from 10 to 25 diseases was completed and evaluated. It is NOT in
production, on evidence:

| | 10-class | 25-class |
| --- | --- | --- |
| Names a condition | 52.0% | 22.2% |
| Correct when named | 100% | 100% |
| Never named | 2 of 10 | 12 of 25 |

Spreading the same evidence across 25 classes lowers every probability, so
the confidence gate is met far less often. Classifier coverage does not
translate into usable diagnostic breadth when evidence gathering is
bounded.

The weights, advice and specialist mappings for all 25 exist and are
tested. Switching would be one line in
`DiseasePredictorService.tenClassModelAsset` - but the measurements say
don't.

---

## 6. Measured results

Full detail in `docs/EVALUATION.md`. Headlines:

**Model-level:** accuracy, precision, recall, F1 all 1.00. This is a
dataset artifact, not performance - 94% of rows are exact duplicates, no
symptom pattern is shared between diseases, 61 of 102 symptoms are unique
to one disease. Report it with the explanation, never alone.

**Application-level:** at 3 rounds x 3 questions, names a condition ~65%
of the time, correct 100% when it does.

**Device** (Realme Narzo 50, Android 13, 4 GB): APK 112.6 MB, RAM ~73 MB
baseline / ~236 MB with the speech model resident, transcription 4-5 s,
prediction instant, full consultation ~30 s. Airplane mode verified on a
release build.

**Verification:** the Dart port matches scikit-learn to 0.00e+00 on
coefficients, intercepts and class order. Softmax confirmed empirically.

---

## 7. Known limitations

- Kannada and Hindi transcription is weaker than English. Mitigated by the
  matcher tolerating romanised output.
- **No benign outcome exists in the label space.** The model must pick
  among 10 conditions and cannot say "this is a common self-limiting
  illness" - the most likely real answer for mild symptoms.
- No lifestyle reasoning (screen time, sleep, hydration).
- No emergency detection, deliberately. A fixed safety list is shown
  instead.
- **The doctor directory is synthetic.** Labelled as such in the app.
- Follow-up questions are chosen by coefficient variance - statistically
  informative, sometimes clinically unintuitive.
- **The entire UI is English.** A Kannada-only reader cannot use the app.
- Not validated with native speakers or clinicians.
- First launch needs one moment of connectivity for the speech model.

---

## 8. Deviations from the synopsis

| Proposed | Built |
| --- | --- |
| DistilBERT-TFLite | Logistic Regression (Dart) |
| TensorFlow Lite / ONNX | None - plain Dart arithmetic |
| Llama-3.2-1B advice | Rule-based advice engine |
| 41 diseases, 132 symptoms | 10 diseases, 86 matchable symptoms |
| 758 MB APK | 112.6 MB APK |

The LR justification is genuine: symptom extraction produces structured
presence/absence features before classification, so a text transformer
solves a problem this pipeline does not have. LR deploys as a 17 KB
weights file with no ML runtime.

The synopsis also contradicted itself on advice generation - its technical
objectives specify a rule-based engine, a later example shows Llama. The
rule-based version was built.

---

## 9. Remaining work

**Localisation** is the big one and unblocks two things at once: the
Kannada-only user, and voice output speaking the right language. Requires
translating UI strings, question templates, disease names and guidance
into Kannada and Hindi. Native-speaker verification needed - the existing
symptom phrases carry the same caveat.

Then: final UI polish, PPT, report, demo video. The README still describes
the retired FastAPI architecture.

---

## 10. Working on this

```bash
cd mobile
flutter pub get
flutter analyze          # expect zero errors, ~48 info-level notes
flutter test             # expect 192 passing
flutter run -d <device>
flutter build apk --release
```

Tests run on the laptop - no phone needed. A phone IS needed for voice
input, TTS, timing, RAM and airplane-mode checks.

`main()` loads unit, voice and text-size preferences before the first
frame, so **hot reload will not pick up changes to it - use hot restart.**

### Notes for whoever continues

Changes were applied by generating Python scripts that patch files by
exact-text anchors, refusing when an anchor is missing. That worked well.
Three things caused repeated failures and are worth avoiding:

- **Escaped dollar signs.** Writing `\\$` in a Python string produces
  broken Dart interpolation. Build the Dart with a placeholder token and
  substitute at the end, and refuse to write if `\\$` survives.
- **Guards that check for a name rather than a declaration.** Checking
  `"_UnitsSheet" in src` matched a *reference* to the class and skipped
  writing the class itself.
- **Removing code by computed offsets.** Stripping a block by index
  arithmetic once took an entire screen class with it. Match exact text
  instead, and verify the expected classes still exist afterwards.
"""

path = r"docs\HANDOVER.md"
if "\\$" in CONTENT.replace("\\\\$", ""):
    sys.exit("REFUSING - unexpected escape in the document body")

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w", encoding="utf-8") as f:
    f.write(CONTENT)
print(f"Wrote {len(CONTENT)} bytes to {path}")