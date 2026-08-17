"""
Tests the guided follow-up flow using the exact partial-symptom scenario
that previously mispredicted Bronchial Asthma instead of Common Cold.

This version answers follow-up questions HONESTLY (based on the real
Common Cold row in the dataset) rather than blindly saying "Yes" to
everything - which is what a real user would do.
"""
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import pandas as pd
from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)

# Load the true Common Cold symptom profile to answer follow-ups honestly
df = pd.read_csv(os.path.join(os.path.dirname(__file__), "..", "ml", "datasets", "training_data.csv"))
df["prognosis"] = df["prognosis"].str.strip()
true_cold_row = df[df["prognosis"] == "Common Cold"].iloc[0]


def section(title):
    print("\n" + "=" * 60)
    print(title)
    print("=" * 60)


# --- Round 1: partial symptoms (the case that previously failed) ---
section("ROUND 1: Initial partial symptoms (fever, cough, sore throat, runny nose, sneezing)")
symptoms = ["high_fever", "cough", "throat_irritation", "runny_nose", "continuous_sneezing"]
denied = []
resp = client.post("/predict", json={"symptoms": symptoms, "denied_symptoms": denied})
data = resp.json()
print(f"Top prediction: {data['top_prediction']}")
print(f"Needs follow-up: {data['needs_followup']}")
if data["needs_followup"]:
    print("Follow-up questions asked:")
    for q in data["follow_up_questions"]:
        print(f"  - [{q['symptom']}] \"{q['question']}\"")

round_num = 1
while data["needs_followup"] and round_num <= 2:
    round_num += 1
    section(f"ROUND {round_num}: Answering follow-ups HONESTLY based on true Common Cold profile")
    for q in data["follow_up_questions"]:
        col = q["symptom"]
        actually_has_it = bool(true_cold_row.get(col, 0) == 1)
        answer = "YES" if actually_has_it else "NO"
        print(f"  Q: \"{q['question']}\" -> {answer}")
        if actually_has_it:
            symptoms.append(col)
        else:
            denied.append(col)

    resp = client.post("/predict", json={"symptoms": symptoms, "denied_symptoms": denied})
    data = resp.json()
    print(f"\nTop prediction: {data['top_prediction']}")
    print(f"Needs follow-up: {data['needs_followup']}")
    print(f"All predictions: {data['all_predictions']}")

section("FINAL RESULT")
if data["top_prediction"]["disease"] == "Common Cold" and data["top_prediction"]["confidence"] >= 0.50:
    print(f"SUCCESS after {round_num} round(s): Common Cold at {data['top_prediction']['confidence']:.2%} confidence")
else:
    top2 = data["all_predictions"][:2]
    print(f"After {round_num} round(s), still below threshold. "
          f"App would show top-2 with a 'consult a doctor for confirmation' note:")
    for p in top2:
        print(f"  - {p['disease']}: {p['confidence']:.2%}")

