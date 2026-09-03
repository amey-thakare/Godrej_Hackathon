import logging
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.models.plant import Plant
from app.schemas.identify import IdentificationResponse, SpeciesIdentification
from app.services.gemini_service import gemini_service
from app.services.plantnet_service import plantnet_service

logger = logging.getLogger(__name__)
router = APIRouter(tags=["Plant Identification"])

MAX_IMAGE_SIZE = 10 * 1024 * 1024
ALLOWED_CONTENT_TYPES = [
    "image/jpeg", "image/png", "image/webp", "image/jpg", "image/heic", "application/octet-stream"
]


@router.post(
    "/identify",
    response_model=IdentificationResponse,
    summary="Identify a plant species from an uploaded image"
)
async def identify_plant(
    image: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """
    Accepts an uploaded plant image (multipart/form-data), performs species identification via
    Gemini Multimodal Vision API (or Pl@ntNet fallback), and matches the species with our curated native plants database.
    """
    # 1. Validate file format / content type
    filename_lower = (image.filename or "").lower()
    is_valid_ext = any(filename_lower.endswith(ext) for ext in [".jpg", ".jpeg", ".png", ".webp", ".heic"])

    if image.content_type not in ALLOWED_CONTENT_TYPES and not is_valid_ext:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid image format '{image.content_type}'. Allowed formats: JPEG, PNG, WEBP."
        )

    # 2. Validate file size
    contents = await image.read()
    if len(contents) > MAX_IMAGE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image file size exceeds maximum limit of 10 MB."
        )

    if len(contents) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded image file is empty."
        )

    # 3. Perform species identification (Gemini Multimodal Vision API primary, Pl@ntNet fallback)
    ident_result = None
    if gemini_service.client:
        try:
            logger.info("Using Gemini Multimodal Vision API for plant identification...")
            ident_result = await gemini_service.identify_species_from_image(
                image_bytes=contents,
                mime_type=image.content_type or "image/jpeg"
            )
        except Exception as err:
            logger.warning(f"Gemini identification failed ({err}), falling back to Pl@ntNet / Mock service.")

    if not ident_result:
        ident_result = await plantnet_service.identify_species(contents, filename=image.filename)

    scic_name = ident_result.get("scientific_name", "")
    comm_name = ident_result.get("common_name")
    confidence = ident_result.get("confidence", 0.0)

    # 4. Search database for matching species in our 12 curated native species
    matched_plant = None
    if scic_name and scic_name != "Unknown":
        conditions = [
            Plant.scientific_name.ilike(f"%{scic_name}%"),
            Plant.plantnet_species_name.ilike(f"%{scic_name}%"),
            Plant.common_name.ilike(f"%{scic_name}%")
        ]
        if comm_name:
            conditions.append(Plant.common_name.ilike(f"%{comm_name}%"))

        stmt = select(Plant).where(or_(*conditions))
        db_result = await db.execute(stmt)
        matched_plant = db_result.scalars().first()

    # 5. Formulate response payload
    message = None
    if confidence < 0.50:
        message = "Identification uncertain. Try capturing a clearer image of the leaves, flowers, bark, or full plant."
    elif not matched_plant:
        message = f"Species identified as '{scic_name}', but detailed information is not available in the curated campus database."

    return IdentificationResponse(
        success=True,
        identification=SpeciesIdentification(
            scientific_name=scic_name,
            common_name=comm_name or (matched_plant.common_name if matched_plant else None),
            confidence=confidence
        ),
        plant=matched_plant,
        message=message
    )
