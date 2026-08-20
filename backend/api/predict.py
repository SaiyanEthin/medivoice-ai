from fastapi import APIRouter, HTTPException
from backend.models.schemas import PredictRequest, PredictResponse
from backend.services import prediction_service, question_service
from backend import config

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
    already_answered = request.symptoms + request.denied_symptoms
    rounds_remaining = request.followup_round < config.MAX_FOLLOWUP_ROUNDS

    # --- GATE 1: MINIMUM EVIDENCE ---
    # Too few confirmed symptoms to say anything meaningful, regardless of
    # what probability the model reports. Ask broadly-informative questions
    # rather than presenting a guess built on 1-2 generic symptoms.
    if len(request.symptoms) < config.MIN_SYMPTOMS_FOR_PREDICTION:
        if rounds_remaining:
            questions = prediction_service.get_informative_symptoms(
                already_answered, n=config.QUESTIONS_PER_ROUND
            )
            if questions:
                return _response(result, True, questions, False, None, request.followup_round)
        # Out of rounds (or no questions left) and still sparse -> report uncertain
        return _response(result, False, [], True, "insufficient_symptoms", request.followup_round)

    # --- GATE 2: CONFIDENCE ---
    if top_confidence < config.CONFIDENCE_THRESHOLD:
        if rounds_remaining:
            top3 = [p["disease"] for p in result["all_predictions"][:3]]
            questions = prediction_service.get_distinguishing_symptoms(
                top3, already_known=already_answered, n=config.QUESTIONS_PER_ROUND
            )
            if questions:
                return _response(result, True, questions, False, None, request.followup_round)
        # Rounds exhausted and still below threshold -> be honest, don't name it
        return _response(result, False, [], True, "low_confidence", request.followup_round)

    # --- Confident enough, and enough evidence ---
    return _response(result, False, [], False, None, request.followup_round)


def _response(result, needs_followup, questions, is_uncertain, reason, round_num):
    return {
        "top_prediction": result["top_prediction"],
        "all_predictions": result["all_predictions"],
        "needs_followup": needs_followup,
        "follow_up_questions": [
            {"symptom": s, "question": question_service.symptom_to_question(s)}
            for s in questions
        ],
        "is_uncertain": is_uncertain,
        "uncertainty_reason": reason,
        "followup_round": round_num,
    }
