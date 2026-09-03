from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models.plant import Plant
from app.schemas.plant import PlantResponse

router = APIRouter(prefix="/plants", tags=["Plants Catalog"])


@router.get("", response_model=List[PlantResponse], summary="Retrieve curated native plant catalog with search")
async def get_plants(
    q: Optional[str] = Query(None, description="Search query for common name, scientific name, or family"),
    db: AsyncSession = Depends(get_db)
):
    """
    Returns the collection of native Indian species.
    Supports optional text filtering across scientific name, common name, and family.
    """
    stmt = select(Plant)
    if q and q.strip():
        query_str = f"%{q.strip().lower()}%"
        stmt = stmt.where(
            or_(
                Plant.common_name.ilike(query_str),
                Plant.scientific_name.ilike(query_str),
                Plant.family.ilike(query_str)
            )
        )

    result = await db.execute(stmt)
    plants = result.scalars().all()
    return plants


@router.get("/{plant_id}", response_model=PlantResponse, summary="Retrieve a single plant profile by ID")
async def get_plant_by_id(plant_id: int, db: AsyncSession = Depends(get_db)):
    """
    Returns complete ecological, botanical, and conservation details for a specific plant ID.
    """
    stmt = select(Plant).where(Plant.id == plant_id)
    result = await db.execute(stmt)
    plant = result.scalar_one_or_none()

    if not plant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Plant with ID {plant_id} not found in curated database."
        )
    return plant
