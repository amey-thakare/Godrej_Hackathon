import hashlib
import logging
from typing import Dict, Any
import httpx
from app.config import settings

logger = logging.getLogger(__name__)

# Sample mock species pool for DEMO_MODE fallback testing
MOCK_SPECIES_POOL = [
    {"scientific_name": "Bougainvillea glabra", "common_name": "Bougainvillea / Paper Flower", "confidence": 0.94},
    {"scientific_name": "Bambusa vulgaris", "common_name": "Common Bamboo", "confidence": 0.91},
    {"scientific_name": "Tecoma stans", "common_name": "Yellow Bells / Yellow Trumpetbush", "confidence": 0.93},
    {"scientific_name": "Chrysanthemum × morifolium", "common_name": "Florist's Chrysanthemum", "confidence": 0.89},
    {"scientific_name": "Helianthus annuus", "common_name": "Common Sunflower", "confidence": 0.95},
    {"scientific_name": "Roystonea regia", "common_name": "Cuban Royal Palm", "confidence": 0.88},
    {"scientific_name": "Cordyline fruticosa", "common_name": "Ti Plant / Cabbage Palm", "confidence": 0.90},
    {"scientific_name": "Tabernaemontana divaricata", "common_name": "Crape Jasmine / Nandiyavattai", "confidence": 0.87},
    {"scientific_name": "Samanea saman", "common_name": "Rain Tree / Thoongu Moonji Maram", "confidence": 0.92},
    {"scientific_name": "Cordyline fruticosa", "common_name": "Ti Plant (Tall grouping)", "confidence": 0.86},
    {"scientific_name": "Pandanus veitchii", "common_name": "Variegated Screw Pine / Dwarf Pandanus", "confidence": 0.89},
]


class PlantNetService:
    def __init__(self):
        self.api_key = settings.PLANTNET_API_KEY
        self.base_url = "https://my-api.plantnet.org/v2/identify/all"

    async def identify_species(self, image_bytes: bytes, filename: str = "plant.jpg") -> Dict[str, Any]:
        """
        Sends plant image to Pl@ntNet API or uses deterministic DEMO_MODE fallback.
        """
        # If real API key is provided and DEMO_MODE is False, call Pl@ntNet API
        if self.api_key and not settings.DEMO_MODE:
            try:
                params = {"api-key": self.api_key}
                files = {"images": (filename, image_bytes, "image/jpeg")}

                async with httpx.AsyncClient(timeout=15.0) as client:
                    response = await client.post(self.base_url, params=params, files=files)
                    response.raise_for_status()
                    data = response.json()

                    results = data.get("results", [])
                    if not results:
                        return {
                            "scientific_name": "Unknown species",
                            "common_name": None,
                            "confidence": 0.0,
                            "raw": data
                        }

                    top = results[0]
                    species_info = top.get("species", {})
                    score = top.get("score", 0.0)

                    scientific_name = (
                        species_info.get("scientificNameWithoutAuthor") or
                        species_info.get("scientificName", "Unknown")
                    )
                    common_names = species_info.get("commonNames", [])
                    common_name = common_names[0] if common_names else None

                    return {
                        "scientific_name": scientific_name,
                        "common_name": common_name,
                        "confidence": round(score, 4),
                        "raw": data
                    }
            except Exception as exc:
                logger.error(f"Pl@ntNet API error: {str(exc)}")

        # DEMO_MODE / Fallback: Pick species deterministically using hash of image bytes
        logger.info("Pl@ntNet Service using DEMO_MODE / deterministic mock pool.")
        hash_idx = int(hashlib.md5(image_bytes).hexdigest(), 16) % len(MOCK_SPECIES_POOL)
        mock_item = MOCK_SPECIES_POOL[hash_idx]

        return {
            "scientific_name": mock_item["scientific_name"],
            "common_name": mock_item["common_name"],
            "confidence": mock_item["confidence"],
            "raw": {"mock": True, "index": hash_idx}
        }


plantnet_service = PlantNetService()
