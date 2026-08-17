from fastapi import APIRouter
from backend.models.schemas import AdviceResponse
from backend.services import advice_service

router = APIRouter()


@router.get("/advice/{disease}", response_model=AdviceResponse)
def get_advice(disease: str):
    return advice_service.get_advice(disease)
