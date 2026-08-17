import json
import os

_ADVICE_PATH = os.path.join(os.path.dirname(__file__), "..", "database", "advice_templates.json")

with open(_ADVICE_PATH, "r", encoding="utf-8") as f:
    _advice_data = json.load(f)


def get_advice(disease: str) -> dict:
    disease = disease.strip()
    if disease not in _advice_data:
        return {
            "disease": disease,
            "severity": "unknown",
            "advice": ["No advice template found for this disease. Please consult a physician."]
        }
    entry = _advice_data[disease]
    return {
        "disease": disease,
        "severity": entry["severity"],
        "advice": entry["advice"]
    }
