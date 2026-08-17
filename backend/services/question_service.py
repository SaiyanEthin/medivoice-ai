import json
import os

_DICT_PATH = os.path.join(os.path.dirname(__file__), "..", "database", "symptom_dictionary.json")

with open(_DICT_PATH, "r", encoding="utf-8") as f:
    _symptom_dict = json.load(f)


def symptom_to_question(symptom_column: str) -> str:
    """
    Converts a raw symptom column name (e.g. 'high_fever') into a natural
    English follow-up question (e.g. 'Do you have fever?'), using the
    first English phrase in our symptom dictionary if available.
    Falls back to a readable version of the column name otherwise.
    """
    entry = _symptom_dict.get(symptom_column)
    if entry and entry.get("en"):
        phrase = entry["en"][0]
    else:
        phrase = symptom_column.replace("_", " ")

    return f"Do you have {phrase}?"
