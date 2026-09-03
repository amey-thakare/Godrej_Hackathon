from typing import Optional
from pydantic import BaseModel
from app.schemas.plant import PlantResponse


class SpeciesIdentification(BaseModel):
    scientific_name: str
    common_name: Optional[str] = None
    confidence: float


class IdentificationResponse(BaseModel):
    success: bool
    identification: SpeciesIdentification
    plant: Optional[PlantResponse] = None
    message: Optional[str] = None
