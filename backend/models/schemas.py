from pydantic import BaseModel
from typing import List


class PredictRequest(BaseModel):
    symptoms: List[str]              # confirmed present
    denied_symptoms: List[str] = []  # confirmed absent (from follow-up "No" answers)


class PredictionResult(BaseModel):
    disease: str
    confidence: float


class FollowUpQuestion(BaseModel):
    symptom: str          # raw column name, e.g. "wheezing" - send back as-is if answered "Yes"
    question: str         # human-readable, e.g. "Do you have wheezing?"


class PredictResponse(BaseModel):
    top_prediction: PredictionResult
    all_predictions: List[PredictionResult]
    needs_followup: bool
    follow_up_questions: List[FollowUpQuestion] = []


class AdviceResponse(BaseModel):
    disease: str
    severity: str
    advice: List[str]


class Doctor(BaseModel):
    name: str
    specialization: str
    district: str
    phone: str
    distance_km: float


class DoctorsResponse(BaseModel):
    disease: str
    doctors: List[Doctor]
