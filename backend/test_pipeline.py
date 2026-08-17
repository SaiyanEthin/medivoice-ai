"""
Validates the full pipeline: symptom input -> prediction -> advice -> doctors.
Run with: python test_pipeline.py
No live server needed - uses FastAPI's TestClient directly.
"""
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)


def section(title):
    print("\n" + "=" * 60)
    print(title)
    print("=" * 60)


# --- Test 1: Health check ---
section("TEST 1: Health check")
resp = client.get("/health")
print(f"Status: {resp.status_code}")
print(f"Body:   {resp.json()}")
assert resp.status_code == 200, "Health check failed"

# --- Test 2: Predict with a Common Cold-like symptom set ---
section("TEST 2: Predict (fever + cough + sore throat -> expect Common Cold)")
payload = {"symptoms": ["high_fever", "cough", "throat_irritation", "runny_nose", "continuous_sneezing"]}
resp = client.post("/predict", json=payload)
print(f"Status: {resp.status_code}")
print(f"Body:   {resp.json()}")
assert resp.status_code == 200
predicted_disease = resp.json()["top_prediction"]["disease"]
confidence = resp.json()["top_prediction"]["confidence"]
print(f"\n-> Predicted: {predicted_disease} (confidence: {confidence})")

# --- Test 3: Predict with an invalid symptom (should reject) ---
section("TEST 3: Predict with unknown symptom (should return 400)")
resp = client.post("/predict", json={"symptoms": ["fever", "made_up_symptom_xyz"]})
print(f"Status: {resp.status_code}")
print(f"Body:   {resp.json()}")
assert resp.status_code == 400, "Should have rejected unknown symptom"
print("-> Correctly rejected (note: 'fever' isn't a valid column name either - must use 'high_fever')")

# --- Test 4: Predict with empty symptoms (should reject) ---
section("TEST 4: Predict with empty symptom list (should return 400)")
resp = client.post("/predict", json={"symptoms": []})
print(f"Status: {resp.status_code}")
print(f"Body:   {resp.json()}")
assert resp.status_code == 400

# --- Test 5: Advice for the predicted disease ---
section(f"TEST 5: Advice for '{predicted_disease}'")
resp = client.get(f"/advice/{predicted_disease}")
print(f"Status: {resp.status_code}")
print(f"Body:   {resp.json()}")
assert resp.status_code == 200

# --- Test 6: Advice for unknown disease (graceful fallback) ---
section("TEST 6: Advice for a disease not in our templates")
resp = client.get("/advice/Some Random Disease")
print(f"Status: {resp.status_code}")
print(f"Body:   {resp.json()}")

# --- Test 7: Doctors for the predicted disease ---
section(f"TEST 7: Doctors for '{predicted_disease}'")
resp = client.get(f"/doctors/{predicted_disease}")
print(f"Status: {resp.status_code}")
print(f"Body:   {resp.json()}")
assert resp.status_code == 200
assert len(resp.json()["doctors"]) > 0, "Should return at least one doctor"

# --- Test 8: Full pipeline for EACH of the 10 diseases ---
section("TEST 8: Full pipeline sanity check across all 10 diseases")
import joblib
symptom_cols = joblib.load(os.path.join(os.path.dirname(__file__), "..", "ml", "exported_models", "symptom_columns.joblib"))

import pandas as pd
df = pd.read_csv(os.path.join(os.path.dirname(__file__), "..", "ml", "datasets", "training_data.csv"))
df["prognosis"] = df["prognosis"].str.strip()

TARGET_DISEASES = ["Common Cold", "Gastroenteritis", "Diabetes", "Hypertension",
                    "Migraine", "Malaria", "Typhoid", "Dengue", "Bronchial Asthma", "Jaundice"]
df = df[df["prognosis"].isin(TARGET_DISEASES)]

all_passed = True
for disease in sorted(df["prognosis"].unique()):
    # Grab one real example row for this disease from the dataset
    row = df[df["prognosis"] == disease].iloc[0]
    symptoms_present = [c for c in symptom_cols if row.get(c, 0) == 1]

    pred_resp = client.post("/predict", json={"symptoms": symptoms_present})
    pred_disease = pred_resp.json()["top_prediction"]["disease"]
    pred_conf = pred_resp.json()["top_prediction"]["confidence"]

    advice_resp = client.get(f"/advice/{pred_disease}")
    doctors_resp = client.get(f"/doctors/{pred_disease}")

    match = "OK" if pred_disease == disease else "MISMATCH"
    if pred_disease != disease:
        all_passed = False

    print(f"[{match}] True: {disease:20s} | Predicted: {pred_disease:20s} | "
          f"Conf: {pred_conf:.3f} | Advice items: {len(advice_resp.json()['advice'])} | "
          f"Doctors found: {len(doctors_resp.json()['doctors'])}")

section("SUMMARY")
if all_passed:
    print("ALL 10 DISEASES CORRECTLY PREDICTED. Pipeline is working end-to-end.")
else:
    print("SOME MISMATCHES FOUND - see MISMATCH rows above.")
