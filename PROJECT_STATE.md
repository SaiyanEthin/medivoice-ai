# MediVoice AI — Project State

Last updated: 2026-08-21

## Purpose
Offline-first multilingual (Kannada/Hindi/English) voice health assistant for
rural and urban India. Final-year BE (AI&ML) capstone, Vijaya Vittala Institute
of Technology, Bengaluru.

Team: Ethin Issac Gerald, Bishnu Charan Das, Chethan Kumar P, Magendran D
Guide: Dr. Naveen Ghorpade

## Three project goals
1. Defensible final-year project + viva
2. Research paper on the *actual implemented* system
3. Possible Play Store deployment

These impose different data/claims standards — see DATA_SOURCES.md.

---

## What is ACTUALLY built and verified

| Component | Status | Verified how |
|---|---|---|
| Dataset (10-disease subset, 1,200 rows) | Done | `ml/training/train_baseline.py` |
| Logistic Regression classifier | Done | 100% on held-out split (see caveat) |
| Random Forest (comparison only) | Done | 100% on held-out split |
| Rule-based advice templates (10 conditions) | Done | `/advice` endpoint tested |
| Symptom dictionary (EN/HI/KN, ~35 entries) | Done | Matcher tested on 6 phrasings |
| Negation detection in matcher | Done | Tested in-app 2026-08-21 |
| Minimum-evidence gate (<3 symptoms) | Done | Tested in-app |
| Uncertainty gate (<0.65 confidence) | Done | Tested in-app |
| Guided follow-up questions (max 2 rounds) | Done | Tested in-app |
| FastAPI dev backend (4 endpoints) | Done | `backend/test_pipeline.py` |
| SQLite healthcare directory (schema + queries) | Done | `/doctors` endpoint tested |
| Flutter: Home Screen | Done | Renders in Chrome |
| Flutter: Voice Input Screen (text stub) | Done | End-to-end tested |
| Flutter: Prediction Screen | Done | Both states tested |
| Flutter: Advice Screen | Done | Tested with Malaria |
| Flutter: Doctor Screen | Done | Tested with Malaria |

## What is NOT built

- Whisper-Tiny STT — **not started**. Input is currently a text field.
- Offline inference — **not started**. App requires the FastAPI backend running.
- Trilingual UI *output* — only input normalization is multilingual; all
  results/advice display in English.
- Android build — **never attempted**. Tested only on Chrome (Flutter web).
- Real healthcare directory data — current records are synthetic.

---

## Honest limitations (must be stated in the paper)

1. **100% accuracy is a dataset artifact, not clinical performance.**
   The source dataset is synthetic/combinatorial: each disease has a clean,
   non-overlapping symptom signature. Real presentations are noisy and
   partial. This number must never be presented as diagnostic accuracy.

2. **The model cannot recognize a common cold from a realistic description.**
   Measured: a textbook 6-symptom cold presentation (fever, cough, runny nose,
   sneezing, sore throat, body ache) returns Bronchial Asthma at ~33%, with
   Common Cold not winning. The dataset's Common Cold rows expect ~12
   simultaneous symptoms. Adding correct-but-partial symptoms *lowers*
   confidence. The gates contain this (app says "Symptoms Unclear" rather than
   naming a wrong condition) but do not fix it.

3. **No "mild / self-limiting / nothing serious" class exists.**
   The model must pick one of 10 diseases. It structurally cannot say
   "this is probably nothing." Everyday causes (cold drink → sore throat)
   are unrepresentable.

4. **Symptom matching is exact-phrase only.** "dizzy head" is not recognized
   because only "dizziness"/"feeling dizzy" are in the dictionary. No stemming,
   no fuzzy matching, no translation model.

5. **Kannada/Hindi phrases are unverified.** Best-effort translations, not
   reviewed by a native speaker. Must be verified before any real deployment
   or paper submission.

6. **Healthcare directory is synthetic.** See DATA_SOURCES.md.

7. **The app is not offline yet.** The Home Screen currently claims it works
   offline. That is the design goal, not the present state. Do not demo with
   network disabled until the offline migration is complete.

---

## Architecture

```
Flutter UI
    ↓
ConsultationProvider (state)
    ↓
ConsultationRepository   ← the swap point for offline migration
    ↓
ApiService (HTTP)  ──── DEVELOPMENT ONLY ────→  FastAPI backend
                                                    ↓
                                        LR model / advice JSON / SQLite
```

Target production architecture replaces `ApiService` with on-device inference.
Nothing above `ConsultationRepository` should need to change.

## Key decisions and why

- **Logistic Regression over DistilBERT** — 17KB vs ~35MB, equal accuracy on
  this dataset, no tokenizer bundling. DistilBERT remains an optional upgrade.
- **Rule-based advice over an LLM** — deterministic, auditable, ~0MB, no
  hallucination risk in a health context. Llama-3.2-1B was considered and
  rejected (628MB, 1-1.5GB RAM, multi-second latency on target hardware).
- **Keyword dictionary over a translation model** — closed symptom vocabulary
  (~35 phrases) makes full translation unnecessary.
- **Provider over Riverpod/Bloc** — appropriate to a 7-screen app.
- **Ternary features (-1/0/1)** — lets "No" answers count as evidence against,
  which binary presence-only encoding could not do.
- **Two independent gates** — minimum-evidence and confidence are separate
  because a model can be confidently wrong on sparse input (measured: 72.4%
  on two symptoms).

## Environment

- Local: `C:\dev\medivoice-ai` (path deliberately avoids spaces — Gradle)
- Repo: github.com/SaiyanEthin/medivoice-ai
- Python: conda env `ai-env`
- Run backend from project ROOT: `python -m uvicorn backend.main:app --reload`
- Run Flutter from `mobile/`: `flutter run` → choose Chrome
- Flutter web uses random localhost ports; backend CORS allows any localhost port
