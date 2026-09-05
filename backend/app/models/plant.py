from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, Index
from app.database import Base


class Plant(Base):
    __tablename__ = "plants"

    id = Column(Integer, primary_key=True, index=True)
    scientific_name = Column(String(255), nullable=False, unique=False, index=True)
    common_name = Column(String(255), nullable=False, index=True)
    family = Column(String(255), nullable=False)
    native_region = Column(String(255), nullable=False)
    conservation_status = Column(String(100), nullable=False)
    ecological_importance = Column(Text, nullable=False)
    description = Column(Text, nullable=False)
    threats = Column(Text, nullable=False)
    conservation_actions = Column(Text, nullable=False)
    habitat = Column(String(255), nullable=False)
    identification_features = Column(Text, nullable=False)
    image_url = Column(String(500), nullable=True)
    plantnet_species_name = Column(String(255), nullable=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    __table_args__ = (
        Index("idx_plant_scic_name", "scientific_name"),
        Index("idx_plant_common_name", "common_name"),
        Index("idx_plant_plantnet_name", "plantnet_species_name"),
    )
