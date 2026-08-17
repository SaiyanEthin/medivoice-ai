from fastapi import APIRouter
from backend.models.schemas import DoctorsResponse
from backend.services import doctor_service

router = APIRouter()


@router.get("/doctors/{disease}", response_model=DoctorsResponse)
def get_doctors(disease: str, limit: int = 5):
    doctors = doctor_service.get_doctors_for_disease(disease, limit=limit)
    return {"disease": disease, "doctors": doctors}
