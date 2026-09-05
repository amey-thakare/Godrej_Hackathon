from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models.plant import Plant
from app.schemas.chat import ChatRequest, ChatResponse
from app.services.gemini_service import gemini_service

router = APIRouter(tags=["AI Botanical Guide"])


@router.post(
    "/chat",
    response_model=ChatResponse,
    summary="Ask questions to the AI Botanical Guide for India's Native Flora"
)
async def chat_botanical_guide(
    request: ChatRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Provides contextual AI botanical responses using Gemini API backed by curated plant database information.
    """
    plant_context = None
    plant_name = None

    if request.plant_id:
        stmt = select(Plant).where(Plant.id == request.plant_id)
        result = await db.execute(stmt)
        plant_obj = result.scalar_one_or_none()

        if plant_obj:
            plant_name = plant_obj.common_name
            plant_context = {
                "common_name": plant_obj.common_name,
                "scientific_name": plant_obj.scientific_name,
                "family": plant_obj.family,
                "native_region": plant_obj.native_region,
                "conservation_status": plant_obj.conservation_status,
                "ecological_importance": plant_obj.ecological_importance,
                "description": plant_obj.description,
                "threats": plant_obj.threats,
                "conservation_actions": plant_obj.conservation_actions,
                "habitat": plant_obj.habitat,
                "identification_features": plant_obj.identification_features,
            }

    reply = await gemini_service.generate_botanical_response(
        user_message=request.message,
        plant_context=plant_context,
        chat_history=request.chat_history
    )

    return ChatResponse(
        success=True,
        reply=reply,
        plant_id=request.plant_id,
        plant_name=plant_name
    )
