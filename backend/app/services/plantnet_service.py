import hashlib
import logging
from typing import Dict, Any
import httpx
from app.config import settings

logger = logging.getLogger(__name__)

# Sample mock species pool for DEMO_MODE fallback testing
MOCK_SPECIES_POOL = [
    {"scientific_name": "Ficus benghalensis", "common_name": "Banyan Tree", "confidence": 0.92},
    {"scientific_name": "Azadirachta indica", "common_name": "Neem", "confidence": 0.89},
    {"scientific_name": "Syzygium cumini", "common_name": "Jamun / Black Plum", "confidence": 0.91},
    {"scientific_name": "Ficus religiosa", "common_name": "Sacred Fig / Peepal", "confidence": 0.88},
    {"scientific_name": "Saraca asoca", "common_name": "Ashoka Tree", "confidence": 0.86},
    {"scientific_name": "Santalum album", "common_name": "Indian Sandalwood", "confidence": 0.84},
    {"scientific_name": "Aegle marmelos", "common_name": "Bael / Sacred Bilva", "confidence": 0.87},
    {"scientific_name": "Butea monosperma", "common_name": "Flame of the Forest", "confidence": 0.93},
    {"scientific_name": "Pongamia pinnata", "common_name": "Karanja / Indian Beech", "confidence": 0.85},
    {"scientific_name": "Alstonia scholaris", "common_name": "Saptaparni / Devil Tree", "confidence": 0.83},
    {"scientific_name": "Helianthus annuus", "common_name": "Sunflower", "confidence": 0.94},
    {"scientific_name": "Nelumbo nucifera", "common_name": "Sacred Lotus", "confidence": 0.95},
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
