"""
Prediction service. Today this loads the sklearn LR model (joblib).
Later, when moving to fully offline Flutter, only THIS file's internals
change (swap for on-device weight lookup) - the API contract stays identical.
"""
import os
import joblib
import numpy as np
import pandas as pd

from backend import config

_ML_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "ml", "exported_models")

_model = joblib.load(os.path.join(_ML_DIR, "lr_model.joblib"))
_symptom_columns = joblib.load(os.path.join(_ML_DIR, "symptom_columns.joblib"))


def get_symptom_columns():
    return _symptom_columns


def predict(symptoms: list[str], denied_symptoms: list[str] = None) -> dict:
    """
    symptoms: list of symptom column names CONFIRMED PRESENT (e.g. ["high_fever", "cough"])
    denied_symptoms: list of symptom column names CONFIRMED ABSENT (e.g. ["breathlessness"])
    Everything else is treated as "unknown" (0).

    Using -1 for confirmed-absent (rather than just omitting it) lets a "No" answer
    actively count as evidence against diseases associated with that symptom -
    without this, "No" answers have zero effect on the prediction.
    """
    denied_symptoms = denied_symptoms or []

    def feature_value(col):
        if col in denied_symptoms:
            return -1
        if col in symptoms:
            return 1
        return 0

    input_vector = pd.DataFrame(
        [[feature_value(col) for col in _symptom_columns]],
        columns=_symptom_columns
    )

    probabilities = _model.predict_proba(input_vector)[0]
    classes = _model.classes_

    ranked = sorted(zip(classes, probabilities), key=lambda x: x[1], reverse=True)

    all_predictions = [{"disease": d, "confidence": round(float(p), 4)} for d, p in ranked]

    return {
        "top_prediction": all_predictions[0],
        "all_predictions": all_predictions
    }


def get_distinguishing_symptoms(top_candidates: list[str], already_known: list[str], n: int = 3) -> list[str]:
    """
    For the guided follow-up flow: given the top-k candidate diseases,
    return symptoms whose coefficients differ most between them -
    i.e. the most USEFUL follow-up questions to ask the user.
    Excludes symptoms already provided by the user.
    """
    class_list = list(_model.classes_)
    indices = [class_list.index(c) for c in top_candidates if c in class_list]
    if len(indices) < 2:
        return []

    coefs = _model.coef_[indices]  # shape: [k, n_features]
    variance_per_symptom = np.var(coefs, axis=0)

    # Zero out symptoms the user already told us about - no point asking again
    for i, col in enumerate(_symptom_columns):
        if col in already_known:
            variance_per_symptom[i] = -1

    top_indices = np.argsort(variance_per_symptom)[::-1][:n]
    return [_symptom_columns[i] for i in top_indices if variance_per_symptom[i] >= 0]


def get_informative_symptoms(already_known: list[str], n: int = 3) -> list[str]:
    """
    For the MINIMUM EVIDENCE gate: when the user has given too few symptoms
    to distinguish anything meaningfully, we can't use top-candidate variance
    (all candidates are near-equally weak). Instead, pick the symptoms that
    are globally most discriminative ACROSS ALL diseases - i.e. the questions
    that split the 10-disease space most usefully.
    """
    variance_per_symptom = np.var(_model.coef_, axis=0)

    for i, col in enumerate(_symptom_columns):
        if col in already_known:
            variance_per_symptom[i] = -1

    top_indices = np.argsort(variance_per_symptom)[::-1][:n]
    return [_symptom_columns[i] for i in top_indices if variance_per_symptom[i] >= 0]


# Kept for backwards compatibility; canonical value lives in backend/config.py
CONFIDENCE_THRESHOLD = config.CONFIDENCE_THRESHOLD
