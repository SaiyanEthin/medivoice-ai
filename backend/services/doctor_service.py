import sqlite3
import os

_DB_PATH = os.path.join(os.path.dirname(__file__), "..", "database", "doctors.db")

DISEASE_TO_SPECIALIZATION = {
    "Common Cold": ["General Physician", "ENT Specialist"],
    "Gastroenteritis": ["General Physician", "Gastroenterologist"],
    "Diabetes": ["Endocrinologist", "General Physician"],
    "Hypertension": ["Cardiologist", "General Physician"],
    "Migraine": ["Neurologist", "General Physician"],
    "Malaria": ["General Physician", "Infectious Disease Specialist"],
    "Typhoid": ["General Physician", "Infectious Disease Specialist"],
    "Dengue": ["General Physician", "Infectious Disease Specialist"],
    "Bronchial Asthma": ["Pulmonologist", "General Physician"],
    "Jaundice": ["Hepatologist", "Gastroenterologist", "General Physician"],
}


def get_doctors_for_disease(disease: str, limit: int = 5) -> list[dict]:
    disease = disease.strip()
    specializations = DISEASE_TO_SPECIALIZATION.get(disease, ["General Physician"])

    conn = sqlite3.connect(_DB_PATH)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    placeholders = ",".join("?" for _ in specializations)
    query = f"""
        SELECT name, specialization, district, phone, distance_km
        FROM doctors
        WHERE specialization IN ({placeholders})
        ORDER BY distance_km ASC
        LIMIT ?
    """
    cur.execute(query, (*specializations, limit))
    rows = cur.fetchall()
    conn.close()

    return [dict(row) for row in rows]
