from fastapi import FastAPI
from backend.api import health, predict, advice, doctors

app = FastAPI(
    title="MediVoice AI Backend",
    description="Offline-first multilingual health assistant - development API",
    version="0.1.0"
)

app.include_router(health.router, tags=["Health"])
app.include_router(predict.router, tags=["Prediction"])
app.include_router(advice.router, tags=["Advice"])
app.include_router(doctors.router, tags=["Doctors"])


@app.get("/")
def root():
    return {"message": "MediVoice AI backend is running. See /docs for API documentation."}
