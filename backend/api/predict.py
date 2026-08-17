from fastapi import APIRouter, HTTPException
from backend.models.schemas import PredictRequest, PredictResponse
from backend.services import prediction_service, question_service

router = APIRouter()


@router.post("/predict", response_model=PredictResponse)
def predict_disease(request: PredictRequest):
    if not request.symptoms:
        raise HTTPException(status_code=400, detail="At least one symptom is required")

    valid_columns = set(prediction_service.get_symptom_columns())
    unknown = [s for s in request.symptoms + request.denied_symptoms if s not in valid_columns]
    if unknown:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown symptom(s): {unknown}. Must match model's symptom vocabulary."
        )

    overlap = set(request.symptoms) & set(request.denied_symptoms)
    if overlap:
        raise HTTPException(
            status_code=400,
            detail=f"Symptom(s) {list(overlap)} cannot be both present and denied."
        )

    result = prediction_service.predict(request.symptoms, request.denied_symptoms)

    top_confidence = result["top_prediction"]["confidence"]
    needs_followup = top_confidence < prediction_service.CONFIDENCE_THRESHOLD

    follow_up_questions = []
    if needs_followup:
        top3_diseases = [p["disease"] for p in result["all_predictions"][:3]]
        already_answered = request.symptoms + request.denied_symptoms
        distinguishing = prediction_service.get_distinguishing_symptoms(
            top3_diseases, already_known=already_answered, n=3
        )
        follow_up_questions = [
            {"symptom": s, "question": question_service.symptom_to_question(s)}
            for s in distinguishing
        ]

    return {
        "top_prediction": result["top_prediction"],
        "all_predictions": result["all_predictions"],
        "needs_followup": needs_followup,
        "follow_up_questions": follow_up_questions
    }
