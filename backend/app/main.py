from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routes import health, plants, identify, chat

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Backend API service for AR + AI Field Intelligence App for Native Plants (Godrej Hackathon)",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.get_cors_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
# Root health check endpoint for Railway deployment detection
app.include_router(health.router)

# API v1 Router inclusion
app.include_router(health.router, prefix=settings.API_V1_STR)
app.include_router(plants.router, prefix=settings.API_V1_STR)
app.include_router(identify.router, prefix=settings.API_V1_STR)
app.include_router(chat.router, prefix=settings.API_V1_STR)


@app.get("/", summary="Root endpoint welcome message")
async def root():
    return {
        "project": settings.PROJECT_NAME,
        "status": "online",
        "demo_mode": settings.DEMO_MODE,
        "docs": "/docs"
    }
