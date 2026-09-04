# MediVoice AI - Evaluation Results

All figures measured on a release build unless stated otherwise. Debug-mode
timings are not reported: they are artificially slow and not representative.

**Test device:** Realme Narzo 50 (RMX3430), Android 13 (API 33), 4 GB RAM,
arm64.

---

## 1. Model-level evaluation

Logistic Regression, 10 classes, 57 symptom features (production model).

| Metric | Result |
| --- | --- |
| Accuracy | 1.00 |
| Precision (weighted) | 1.00 |
| Recall (weighted) | 1.00 |
| F1 (weighted) | 1.00 |
| Cross-validation | 5-fold stratified, on deduplicated data |
| Leave-one-out CV | 1.00 |

### These numbers must not be reported as clinical performance

Perfect scores are a property of the dataset, not evidence of diagnostic
skill. Investigation established:

- The source dataset has 4,920 rows, but **4,616 (94%) are exact
  duplicates**. Each disease has only 5-10 genuinely unique symptom
  combinations, repeated to pad the row count.
- **No symptom pattern is shared by two different diseases.** There is no
  ambiguous example anywhere in the data for a model to get wrong.
- **61 of 102 symptom columns appear in exactly one disease**, acting as
  near-unique identifiers.
- **6 of 25 diseases have a symptom present in 100% of their own rows and
  0% of every other disease's** - a single conditional would classify them.
- The classes are linearly separable: Logistic Regression and a
  hard-margin LinearSVC both reach 1.00 training accuracy.
- Logistic Regression and Random Forest both reach 1.00 while relying on
  **different features** (Spearman rho = 0.14 between their importance
  rankings, p = 0.17). Two structurally different algorithms solving the
  task by different routes indicates trivial separability rather than
  shared modelling skill.
- Malaria and Typhoid share the most symptom vocabulary of any pair
  (Jaccard 0.46) yet produce **zero** misclassifications between them.

Deduplication was applied before splitting. Without it, duplicate rows
appear in both train and test folds, which is genuine data leakage.

## 2. Application-level evaluation

Model accuracy does not equal application usefulness. This measures the
full pipeline including the confidence gates and follow-up interaction.

Simulated over every unique dataset row, starting from 2, 3 or 4 randomly
sampled symptoms, with follow-ups answered truthfully from the same row.

| Configuration | Named a condition | Correct when named | Diseases never named |
| --- | --- | --- | --- |
| 2 rounds x 3 questions | 52.0% | 100% | 2 of 10 |
| 2 x 4 | 60.2% | 100% | 2 of 10 |
| 3 x 3 (current) | 65.4% | 100% | 1 of 10 |
| 3 x 4 | 71.1% | 100% | 1 of 10 |
| 3 x 5 | 81.3% | 100% | 0 of 10 |

Confidence threshold 0.65 throughout. **Correctness stays at 100% at every
budget** - a wider budget costs user effort, not safety.

Lowering the threshold is a different matter: at 0.45 the same model
produces 21+ confidently wrong answers. The gates trade coverage for
precision deliberately, and that trade is worth keeping.

**Caveat:** simulated users answer every follow-up correctly from ground
truth. Real users misremember and speech recognition introduces errors, so
these are optimistic ceilings, not expected field accuracy.

### 25-class expansion (experiment, not shipped)

Expanding to 25 diseases was built, evaluated, and rejected on evidence:

| | 10-class | 25-class |
| --- | --- | --- |
| Named a condition | 52.0% | 22.2% |
| Correct when named | 100% | 100% |
| Diseases never named | 2 of 10 | 12 of 25 |
| Best safe setting | 90.2% @ 25 questions | 59.7% @ 25 questions |

Spreading the same evidence across 25 classes lowers every probability, so
the confidence gate is met far less often. **Classifier coverage does not
translate into usable diagnostic breadth when evidence gathering is
bounded.** The 10-class model was retained for the prototype.

## 3. Device performance

| Metric | Result |
| --- | --- |
| APK size (universal release) | 112.6 MB |
| APK size (arm64 only) | 82.1 MB |
| Native libraries | 81 MB of the 82 MB arm64 build |
| Application Dart code | 86 KB |
| Exported LR weights | ~17 KB |
| RAM, app baseline | ~73 MB |
| RAM, speech model resident | ~236 MB |
| RAM increase during inference | negligible (~1.6 MB) |
| Speech-to-text, model cached | 4-5 s |
| First run (incl. one-time model download) | ~20 s |
| Disease prediction | instant, below measurement threshold |
| Full consultation, 3 follow-up rounds | ~30 s |

Peak RAM is ~6% of the device's 4 GB, within the low-resource target.

**Where the cost sits:** speech infrastructure dominates both size and
memory. The classifier is negligible by comparison - 17 KB of weights and
inference too fast to time. The application's own Dart code is 86 KB.

**Per-ABI splits** would reduce the shipped APK to roughly 35-40 MB on an
arm64 device. Not done for the prototype; noted as future work.

## 4. Offline operation

Verified on the release build with airplane mode enabled: voice input,
transcription, symptom matching, follow-up questions, prediction, health
advice and doctor recommendation all completed with no network.

**One qualification, stated precisely:** the speech model (~75 MB) is
downloaded once on first use and cached. Every consultation after that is
fully offline. First launch requires one moment of connectivity.

## 5. Implementation verification

The Dart port was verified against the trained scikit-learn model:

- Class order, symptom column order (checked three ways), coefficients and
  intercepts: **maximum absolute difference 0.00e+00**.
- Probability calculation: scikit-learn's `predict_proba` matches softmax
  to 0.00e+00 and differs from one-vs-rest by 8.29e-02, confirming the
  Dart implementation empirically rather than by assumption.
- Six symptom sets compared across scikit-learn, the exported JSON, and
  the running Flutter app: agreement to four decimal places.

## 6. Known limitations

- Kannada and Hindi transcription is weaker than English (Whisper-Tiny on
  lower-resource languages). Mitigated: the symptom matcher tolerates
  romanised output, so an imperfect transcription can still match.
- **No benign outcome exists in the label space.** The model must choose
  among 10 conditions and cannot report "this is a common self-limiting
  illness", which is the most likely real answer for mild symptoms. Such
  cases surface as "Symptoms Unclear" with self-care guidance.
- No reasoning over lifestyle factors (screen time, sleep, hydration).
- No emergency detection. Deliberate: a rushed red-flag detector risks
  both false alarm and false reassurance. A fixed safety list is shown
  instead.
- **The doctor directory is synthetic demonstration data.** The records are
  not real practitioners and must not be presented as such.
- Several symptoms map to more than one model feature by design (for
  example "stomach pain" matches abdominal_pain, belly_pain and
  stomach_pain), so a single phrase can contribute multiple features
  toward the 3-symptom minimum-evidence gate. Known trade-off: removing
  the multi-mapping would lose recall for phrasings the model needs.
- Follow-up questions are selected by coefficient variance across current
  candidates - statistically informative, but sometimes clinically
  unintuitive to the user.
- Not validated with native speakers or clinicians.
- No consultation history; each session starts fresh.

## 7. Deviation from the original synopsis

| Proposed | Implemented |
| --- | --- |
| DistilBERT-TFLite classifier | Logistic Regression (Dart) |
| TensorFlow Lite / ONNX Runtime | None - plain Dart arithmetic |
| Llama-3.2-1B advice generation | Rule-based advice engine |
| 41 diseases, 132 symptoms | 10 diseases, 86 matchable symptoms |
| 758 MB APK | 112.6 MB APK |

**Justification for Logistic Regression.** The symptom extraction layer
converts free-form speech into structured presence/absence features before
classification. A transformer operating on raw text solves a problem this
pipeline does not have. Logistic Regression consumes those features
directly, deploys as a 17 KB weights file with no ML runtime dependency,
and runs with imperceptible latency - appropriate for offline deployment on
low-resource devices.

The synopsis was also internally inconsistent on advice generation: its
technical objectives specify a structured rule-based advice engine, while
a later illustrative example shows Llama-generated advice. The rule-based
approach was implemented, matching the stated objective and avoiding
hallucinated medical guidance.

No claim of superiority over DistilBERT is made. The two were not compared.
