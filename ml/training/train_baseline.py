import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, classification_report
import joblib

# Load data
df = pd.read_csv('training_data.csv')
df = df.drop(columns=['Unnamed: 133'], errors='ignore')

TARGET_DISEASES = ['Common Cold', 'Gastroenteritis', 'Diabetes ', 'Hypertension ',
                    'Migraine', 'Malaria', 'Typhoid', 'Dengue', 'Bronchial Asthma', 'Jaundice']

df = df[df['prognosis'].isin(TARGET_DISEASES)].copy()
df['prognosis'] = df['prognosis'].str.strip()  # clean trailing spaces like "Diabetes "

print(f"Total rows for our 10 diseases: {len(df)}")
print(df['prognosis'].value_counts())
print()

X = df.drop(columns=['prognosis'])
y = df['prognosis']

# Drop symptom columns that are all-zero for our subset (saves space on mobile later)
nonzero_cols = X.columns[(X.sum(axis=0) > 0)]
X = X[nonzero_cols]
print(f"Symptoms used (out of 132): {len(nonzero_cols)}")
print()

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

# --- Logistic Regression ---
lr = LogisticRegression(max_iter=1000)
lr.fit(X_train, y_train)
lr_preds = lr.predict(X_test)

print("=== Logistic Regression ===")
print(f"Accuracy:  {accuracy_score(y_test, lr_preds):.4f}")
print(f"Precision: {precision_score(y_test, lr_preds, average='weighted'):.4f}")
print(f"Recall:    {recall_score(y_test, lr_preds, average='weighted'):.4f}")
print(f"F1:        {f1_score(y_test, lr_preds, average='weighted'):.4f}")
print()

# --- Random Forest (for comparison) ---
rf = RandomForestClassifier(n_estimators=100, random_state=42)
rf.fit(X_train, y_train)
rf_preds = rf.predict(X_test)

print("=== Random Forest ===")
print(f"Accuracy:  {accuracy_score(y_test, rf_preds):.4f}")
print(f"Precision: {precision_score(y_test, rf_preds, average='weighted'):.4f}")
print(f"Recall:    {recall_score(y_test, rf_preds, average='weighted'):.4f}")
print(f"F1:        {f1_score(y_test, rf_preds, average='weighted'):.4f}")
print()

# Save the better model + symptom column list (needed later for the app's input vector)
joblib.dump(lr, 'lr_model.joblib')
joblib.dump(rf, 'rf_model.joblib')
joblib.dump(list(nonzero_cols), 'symptom_columns.joblib')

print("Saved: lr_model.joblib, rf_model.joblib, symptom_columns.joblib")
print(f"\nModel file sizes:")
import os
for f in ['lr_model.joblib', 'rf_model.joblib']:
    print(f"  {f}: {os.path.getsize(f)/1024:.1f} KB")
