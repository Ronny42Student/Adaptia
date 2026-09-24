from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.api.auth import router as auth_router

app = FastAPI(title="AdaptIA API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)


@app.get("/")
def root():
    return {"message": "AdaptIA API is running"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/docs")
def swagger():
    return
