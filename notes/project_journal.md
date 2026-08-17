# MediVoice AI — Project Journal

Keep this updated daily. This becomes your memory for the viva — write down
problems you hit and how you solved them, not just what got finished.

---

## Day 1 — Dataset, Model, Backend

**Done:**
- Scoped project to 10 diseases (Common Cold, Gastroenteritis, Diabetes, Hypertension,
  Migraine, Malaria, Typhoid, Dengue, Bronchial Asthma, Jaundice) out of the full 41 in
  the Kaggle-style 132-symptom dataset.
- Trained Logistic Regression + Random Forest baselines. Both hit 100% accuracy on
  clean/complete symptom sets (expected — dataset is synthetic/combinatorial, not noisy
  real-world data. Need to say this honestly in the report if asked "why 100%?").
- Reduced symptom vocabulary from 132 to 57 relevant columns for our 10 diseases; of
  those, ~33 are realistically "speakable" (things a person would say out loud) —
  the rest are clinical/derived labels (e.g. `family_history`, `toxic_look_(typhos)`)
  that a user would never voice naturally.
- Built rule-based advice templates (no LLM — decided against Llama-3.2 for size/speed/
  safety reasons: ~628MB + slow inference + hallucination risk not worth it for a
  health app).
- Built Kannada/Hindi/English symptom keyword dictionary (NOT full translation — just
  keyword mapping for our 33 speakable symptoms). Needs native-speaker verification
  before final demo — translations are best-effort right now.
- Built FastAPI backend: `/predict`, `/advice/{disease}`, `/doctors/{disease}`, `/health`.
- Built SQLite doctor DB, seeded with 15 sample doctors across Bengaluru + nearby districts.

**Problem found and fixed:** Model predicted wrong disease (Bronchial Asthma instead of
Common Cold) when given a realistic PARTIAL symptom list (5 symptoms instead of the full
clean training pattern). This matters because voice input will almost always be partial.

**Fix:** Built a guided follow-up question flow — if top prediction confidence is below
50%, ask 2-3 targeted yes/no questions (chosen by which symptoms best distinguish the
top-3 candidate diseases). Capped at 2 rounds (6 questions max) to keep it usable.

**Second problem found:** Model only had binary features (symptom present = 1, absent =
0 by omission) — so answering "No" to a follow-up did literally nothing. Fixed by
switching to ternary features (-1 = confirmed absent, 0 = unknown, 1 = confirmed
present) — this let "No" answers actually count as negative evidence, without needing
to retrain the model.

**Verified:** after the fix, honest yes/no answers correctly pushed the prediction toward
Common Cold (25% → 35% → 51% confidence across follow-up rounds) instead of drifting
wrong. If still below 50% after 2 rounds, app shows top-2 diseases + "consult a doctor"
rather than forcing a guess.

**Next:** Flutter screens, one at a time.

---

## Day 2 — Flutter Architecture + Home Screen

**Done:**
- Locked Flutter architecture: Provider for state management (not Riverpod/Bloc — too
  much ceremony for a 7-screen student project), `core/` folder for theme/config/routes,
  `repositories/` layer between UI and API so offline swap later doesn't touch the UI.
- Built Home Screen: app intro, language availability chips (English/Hindi/Kannada),
  "Start Consultation" button, About link. Both nav buttons currently go to a
  placeholder screen since Voice Input / About aren't built yet.

**Important honest note:** Home Screen text says "works fully offline" — that's the
FINAL product's goal, not true yet during development (still calling local FastAPI
over HTTP). Don't demo with WiFi off until offline conversion milestone is actually done.

**Next:** Voice Input Screen.

---

## Day 3 — (fill in as you go)

**Done:**

**Problems:**

**Next:**
