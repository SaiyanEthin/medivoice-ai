# MediVoice AI - Backend (Development Phase)

## Structure
```
medivoice-ai/
├── backend/        # FastAPI app (dev-only, replaced by offline inference later)
│   ├── api/         # Route handlers: predict, advice, doctors, health
│   ├── models/       # Pydantic request/response schemas
│   ├── services/     # Business logic: prediction, advice, doctor lookup
│   ├── database/     # doctors.db (SQLite), advice_templates.json, symptom_dictionary.json
│   └── main.py       # App entrypoint
├── ml/
│   ├── datasets/      # training_data.csv (10-disease subset)
│   ├── training/       # train_baseline.py
│   └── exported_models/ # lr_model.joblib, rf_model.joblib, lr_model_weights.json
├── mobile/          # Flutter app (not yet built)
└── docs/
```

## Setup
```bash
cd medivoice-ai
pip install fastapi uvicorn scikit-learn pandas joblib httpx --break-system-packages
```

## Seed the doctor database (already done once, re-run if you delete doctors.db)
```bash
cd backend/database
python seed_doctors.py
```

## Run the full pipeline test (no server needed)
```bash
cd medivoice-ai
python backend/test_pipeline.py
```

## Run the live dev server
```bash
cd medivoice-ai
uvicorn backend.main:app --reload
```
Then visit http://127.0.0.1:8000/docs for interactive API docs.

## Endpoints
- `GET /health` - health check
- `POST /predict` - body: `{"symptoms": ["high_fever", "cough", ...]}` → predicted disease + confidence
- `GET /advice/{disease}` - rule-based advice for a disease
- `GET /doctors/{disease}` - nearby doctors for that disease's specialization

## Known limitation (important for report/viva)
The model was trained on clean, complete symptom combinations from a synthetic dataset,
so it hits ~99% accuracy on FULL symptom sets but is noticeably less confident on PARTIAL
symptom input (e.g. only 3-5 symptoms) - which is what real voice input will usually give.
This is why the guided follow-up question feature (asking 2-3 targeted yes/no questions
after initial voice input) is planned as the next reliability improvement, not just a UX nicety.

## Next milestones
1. Guided follow-up question logic (which symptoms to ask about, given top-3 candidates)
2. Flutter UI calling this API
3. Whisper-Tiny integration for voice input
4. Offline conversion (export weights, remove FastAPI dependency)
5. DistilBERT upgrade path (optional, last)
