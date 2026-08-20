# MediVoice AI — Data Sources

Every dataset used, where it came from, and what may be claimed about it.
Maintained for research reproducibility and deployment compliance.

---

## 1. Symptom–Disease Dataset

| Field | Value |
|---|---|
| Source | github.com/anujdutt9/Disease-Prediction-from-Symptoms (`dataset/training_data.csv`) |
| Retrieved | 2026-07 |
| Original size | 4,920 rows, 132 symptom columns, 41 disease labels |
| Used subset | 1,200 rows, 57 symptom columns, 10 disease labels |
| Local path | `ml/datasets/training_data.csv` |
| License | Not explicitly stated in the repository — **must be confirmed before publication** |
| Nature | **Synthetic / combinatorial**, not collected clinical records |

### Preprocessing
- Filtered to 10 target diseases (120 rows each, perfectly balanced)
- Dropped all-zero symptom columns (132 → 57)
- Stripped trailing whitespace from labels (e.g. `"Diabetes "`)
- Dropped the trailing unnamed empty column

### What may be claimed
- Accuracy figures on this dataset, clearly labelled as dataset performance
- The balanced class distribution and preprocessing steps

### What may NOT be claimed
- Any real-world or clinical diagnostic accuracy
- That 100% accuracy reflects app performance on real users
- Generalisation beyond the 10 selected conditions

### Known limitations
- Each disease has a clean, near-unique symptom signature — trivially separable
- No noise, comorbidity, partial presentation, or severity gradation
- No mild/self-limiting category
- Symptom columns include clinical/derived labels a patient would never say
  aloud (`toxic_look_(typhos)`, `family_history`, `irregular_sugar_level`)

---

## 2. Symptom Phrase Dictionary (EN / HI / KN)

| Field | Value |
|---|---|
| Source | **Authored by the project team**, not derived from a corpus |
| Path | `backend/database/symptom_dictionary.json` (mirrored to `mobile/assets/data/`) |
| Size | ~35 symptom columns, multiple phrases each |
| Status | English usable; **Hindi and Kannada UNVERIFIED** |

Purpose: maps natural spoken phrases to internal English symptom IDs, avoiding
a translation model. Matching is exact-substring, longest-phrase-first.

**Action required:** Kannada and Hindi phrases are best-effort translations and
have not been reviewed by a native speaker. They must be verified before any
user-facing deployment or paper claim about multilingual support.

Removed mappings: `"cold"` → `continuous_sneezing` (ambiguous: illness vs
temperature sensation; also a diagnosis, not a symptom).

---

## 3. Advice Templates

| Field | Value |
|---|---|
| Source | **Authored by the project team** |
| Path | `backend/database/advice_templates.json` |
| Coverage | 10 conditions, severity band + 4 guidance items each |
| Clinical review | **NONE** |

Content is general first-aid/self-care guidance (rest, fluids, when to seek
care). Deliberately avoids dosages and prescriptions.

**Not clinically reviewed.** Before deployment, these should be checked against
a recognised source (e.g. Ministry of Health & Family Welfare guidance, WHO
factsheets) or reviewed by a qualified practitioner, and that review recorded
here.

---

## 4. Healthcare Directory — **SYNTHETIC, DEVELOPMENT ONLY**

| Field | Value |
|---|---|
| Source | **Fabricated for testing. No record corresponds to a real person or facility.** |
| Path | `backend/database/doctors.db`, seeded by `backend/database/seed_doctors.py` |
| Records | 15 |
| Status | Development/demo only — **must not ship to real users** |

Names, phone numbers, districts and distances are all invented. Phone numbers
follow a sequential pattern (9880011223…) and belong to no one, but are
formatted like valid Indian mobile numbers — they should be masked before any
public demo.

What IS real and reusable: the SQLite schema, the disease→specialization
mapping, the distance-sorted query, and the offline access pattern.

UI already displays: *"Sample directory data for demonstration."* Keep it.

### Production replacement — not yet started
Preferred direction is public/government facility data rather than private
practitioners, which also fits the rural-access objective better:
- Primary Health Centres (PHCs)
- Community Health Centres (CHCs)
- Government hospitals / district hospitals

Candidate sources to investigate (**none evaluated yet — do not cite until
verified for licence and accuracy**): National Health Mission / state health
department directories, data.gov.in health facility datasets, HMIS facility
registries.

Target schema for production:
`facility_name, provider_type, specialization, area, taluk, district, state,
contact, latitude, longitude, source, last_verified`

Do not populate production data by hand or from model output.

---

## Data state separation

| State | Synthetic OK? | Standard |
|---|---|---|
| Development | Yes | Must exercise the code path |
| Research | Only if disclosed | Documented, sourced, reproducible; synthetic nature stated explicitly |
| Production | **No** | Verified, licensed, accurate; no fabricated provider identities |

These must never be conflated.
