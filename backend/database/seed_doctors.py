"""
Creates doctors.db (SQLite) and seeds it with sample doctor records.
Run this once: python seed_doctors.py
"""
import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "doctors.db")

# Maps each of our 10 diseases to the relevant specialization(s)
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

# Sample doctor records: (name, specialization, district, phone, distance_km)
SAMPLE_DOCTORS = [
    ("Dr. Anitha Rao", "General Physician", "Bengaluru Urban", "9880011223", 3.2),
    ("Dr. Suresh Kumar", "General Physician", "Bengaluru Rural", "9880011224", 8.5),
    ("Dr. Meera Nair", "Endocrinologist", "Bengaluru Urban", "9880011225", 5.1),
    ("Dr. Prakash Shetty", "Cardiologist", "Bengaluru Urban", "9880011226", 4.7),
    ("Dr. Lakshmi Iyer", "Neurologist", "Bengaluru Urban", "9880011227", 6.3),
    ("Dr. Ravi Chandran", "Pulmonologist", "Bengaluru Urban", "9880011228", 7.0),
    ("Dr. Fatima Khan", "Gastroenterologist", "Bengaluru Urban", "9880011229", 3.9),
    ("Dr. Deepak Gowda", "Hepatologist", "Bengaluru Urban", "9880011230", 9.2),
    ("Dr. Sunita Patil", "Infectious Disease Specialist", "Bengaluru Urban", "9880011231", 5.6),
    ("Dr. Manoj Bhat", "ENT Specialist", "Bengaluru Urban", "9880011232", 4.0),
    ("Dr. Kavya Reddy", "General Physician", "Mandya", "9880011233", 42.0),
    ("Dr. Arjun Naik", "General Physician", "Tumkur", "9880011234", 65.0),
    ("Dr. Shalini Menon", "Cardiologist", "Mysuru", "9880011235", 140.0),
    ("Dr. Vikram Rao", "Endocrinologist", "Mysuru", "9880011236", 142.0),
    ("Dr. Pooja Hegde", "General Physician", "Ramanagara", "9880011237", 50.0),
]


def create_and_seed():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    cur.execute("DROP TABLE IF EXISTS doctors")
    cur.execute("""
        CREATE TABLE doctors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            specialization TEXT NOT NULL,
            district TEXT NOT NULL,
            phone TEXT NOT NULL,
            distance_km REAL NOT NULL
        )
    """)

    cur.executemany(
        "INSERT INTO doctors (name, specialization, district, phone, distance_km) VALUES (?, ?, ?, ?, ?)",
        SAMPLE_DOCTORS
    )

    conn.commit()
    print(f"Seeded {cur.rowcount if cur.rowcount != -1 else len(SAMPLE_DOCTORS)} rows into doctors table")

    cur.execute("SELECT COUNT(*) FROM doctors")
    print("Total doctors in DB:", cur.fetchone()[0])

    conn.close()
    print(f"Database created at: {DB_PATH}")


if __name__ == "__main__":
    create_and_seed()
