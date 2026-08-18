from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.api import health, predict, advice, doctors

app = FastAPI(
    title="MediVoice AI Backend",
    description="Offline-first multilingual health assistant - development API",
    version="0.1.0"
)

# Flutter web assigns a random localhost port each run (e.g. localhost:60260),
# so we allow any localhost/127.0.0.1 origin during development rather than
# hardcoding one port. This is fine for a local dev backend - would need to
# be tightened (specific origins only) if this were ever public-facing.
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, tags=["Health"])
app.include_router(predict.router, tags=["Prediction"])
app.include_router(advice.router, tags=["Advice"])
app.include_router(doctors.router, tags=["Doctors"])


@app.get("/")
def root():
    return {"message": "MediVoice AI backend is running. See /docs for API documentation."}