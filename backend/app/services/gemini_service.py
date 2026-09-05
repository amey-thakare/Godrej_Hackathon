import json
import logging
from typing import Dict, Any, Optional
from google import genai
from google.genai import types
from app.config import settings

logger = logging.getLogger(__name__)

BOTANICAL_SYSTEM_INSTRUCTION = """You are an expert botanical and conservation AI guide specializing in India's native, endemic, and cultivated flora.

Your purpose is to provide rich, scientifically accurate, and engaging answers about plants, ecosystems, distribution across India, ecological roles, and conservation.

1. When a specific Curated Plant Record is supplied, use it as your primary reference for that plant.
2. For general botanical, agricultural, geographic, or ecological questions about any plant (e.g. sunflowers, roses, neem, Western Ghats flora), use your deep botanical knowledge to provide complete, informative, and helpful answers. Never state that information is "unavailable in the curated database".
3. Promote responsible plant observation, ecological restoration, and environmental stewardship.
4. Keep responses concise, well-formatted with markdown headings/bullet points, and easy to read for field users."""


class GeminiService:
    def __init__(self):
        # Support API key in either GEMINI_API_KEY or PLANTNET_API_KEY
        self.api_key = settings.GEMINI_API_KEY if (settings.GEMINI_API_KEY and settings.GEMINI_API_KEY != "your_gemini_api_key_here") else settings.PLANTNET_API_KEY
        self.client = None
        if self.api_key:
            try:
                self.client = genai.Client(api_key=self.api_key)
                logger.info("Gemini client successfully initialized.")
            except Exception as e:
                logger.error(f"Failed to initialize Gemini client: {e}")

    async def identify_species_from_image(
        self,
        image_bytes: bytes,
        mime_type: str = "image/jpeg"
    ) -> Dict[str, Any]:
        """
        Uses Gemini Multimodal Vision API to identify plant species from an uploaded image.
        """
        if not self.client:
            raise ValueError("Gemini client is not initialized.")

        try:
            # Fall back to image/jpeg if generic octet-stream is passed
            valid_mime = mime_type if mime_type.startswith("image/") else "image/jpeg"
            image_part = types.Part.from_bytes(data=image_bytes, mime_type=valid_mime)

            prompt = (
                "You are an expert Indian botanist. Examine this plant image in detail (leaves, flowers, bark, shape).\n"
                "Identify the plant species and return ONLY a valid JSON object with the following schema:\n"
                "{\n"
                '  "scientific_name": "Latin binomial scientific name (e.g. Azadirachta indica)",\n'
                '  "common_name": "Primary common name (e.g. Neem)",\n'
                '  "confidence": 0.92\n'
                "}\n"
                "If the image is unclear or not a plant, set scientific_name to 'Unknown', common_name to null, and confidence to 0.20."
            )

            response = self.client.models.generate_content(
                model="gemini-3.6-flash",
                contents=[image_part, prompt],
                config=types.GenerateContentConfig(
                    response_mime_type="application/json"
                )
            )

            result_json = json.loads(response.text)
            scientific_name = result_json.get("scientific_name", "Unknown")
            common_name = result_json.get("common_name")
            confidence = float(result_json.get("confidence", 0.85))

            return {
                "scientific_name": scientific_name,
                "common_name": common_name,
                "confidence": min(max(confidence, 0.0), 1.0),
                "raw": result_json
            }
        except Exception as exc:
            logger.error(f"Gemini Vision Identification error: {str(exc)}")
            raise exc

    async def generate_botanical_response(
        self,
        user_message: str,
        plant_context: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Generates contextual response for AI Botanical Guide using Gemini API or DEMO_MODE fallback.
        """
        if settings.DEMO_MODE or not self.client:
            logger.info("Gemini Service running in DEMO_MODE / key missing fallback.")
            if plant_context:
                name = plant_context.get("common_name", "this plant")
                scic_name = plant_context.get("scientific_name", "")
                family = plant_context.get("family", "")
                importance = plant_context.get("ecological_importance", "")
                status = plant_context.get("conservation_status", "")
                return (
                    f"**{name}** (*{scic_name}*) is a key native Indian species in the family **{family}**.\n\n"
                    f"**Ecological Significance**: {importance}\n\n"
                    f"**Conservation Status**: {status}\n\n"
                    f"To protect this species, avoid damaging its habitat and support native tree planting initiatives."
                )
            return (
                "Hello! I am your AI Botanical Guide specializing in India's native flora. "
                "Ask me about plant identification, ecological roles, or conservation steps across India."
            )

        try:
            # Build prompt with plant context if available
            prompt_content = f"User Question: {user_message}\n\n"
            if plant_context:
                prompt_content += (
                    f"Curated Plant Record:\n"
                    f"- Common Name: {plant_context.get('common_name')}\n"
                    f"- Scientific Name: {plant_context.get('scientific_name')}\n"
                    f"- Family: {plant_context.get('family')}\n"
                    f"- Native Region: {plant_context.get('native_region')}\n"
                    f"- Conservation Status: {plant_context.get('conservation_status')}\n"
                    f"- Ecological Importance: {plant_context.get('ecological_importance')}\n"
                    f"- Description: {plant_context.get('description')}\n"
                    f"- Threats: {plant_context.get('threats')}\n"
                    f"- Conservation Actions: {plant_context.get('conservation_actions')}\n"
                    f"- Identification Features: {plant_context.get('identification_features')}\n"
                )

            response = self.client.models.generate_content(
                model="gemini-3.6-flash",
                contents=prompt_content,
                config=types.GenerateContentConfig(
                    system_instruction=BOTANICAL_SYSTEM_INSTRUCTION
                )
            )
            return response.text
        except Exception as exc:
            logger.error(f"Gemini API error: {str(exc)}")
            return f"The Botanical Guide is operating in offline mode: {user_message}"


gemini_service = GeminiService()
