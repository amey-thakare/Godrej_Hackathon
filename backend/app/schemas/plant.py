from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class PlantBase(BaseModel):
    scientific_name: str
    common_name: str
    family: str
    native_region: str
    conservation_status: str
    ecological_importance: str
    description: str
    threats: str
    conservation_actions: str
    habitat: str
    identification_features: str
    image_url: Optional[str] = None
    plantnet_species_name: Optional[str] = None


class PlantCreate(PlantBase):
    pass


class PlantUpdate(BaseModel):
    scientific_name: Optional[str] = None
    common_name: Optional[str] = None
    family: Optional[str] = None
    native_region: Optional[str] = None
    conservation_status: Optional[str] = None
    ecological_importance: Optional[str] = None
    description: Optional[str] = None
    threats: Optional[str] = None
    conservation_actions: Optional[str] = None
    habitat: Optional[str] = None
    identification_features: Optional[str] = None
    image_url: Optional[str] = None
    plantnet_species_name: Optional[str] = None


class PlantResponse(PlantBase):
    id: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
