from fastapi import APIRouter

router = APIRouter(tags=["Health"])


@router.get("/health", summary="Health check endpoint for Railway deployment and monitoring")
async def health_check():
    return {"status": "ok"}
