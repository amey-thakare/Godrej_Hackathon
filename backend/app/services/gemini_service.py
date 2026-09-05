import json
import logging
from typing import Dict, Any, Optional, List
from google import genai
from google.genai import types
from app.config import settings

logger = logging.getLogger(__name__)

BOTANICAL_SYSTEM_INSTRUCTION = """You are an expert botanical and conservation AI guide specializing in India's native, endemic, and cultivated flora, as well as global plant biology.

Your mission is to provide rich, scientifically accurate, and deeply engaging answers about plants, ecosystems, distribution across India, ecological roles, and practical plant conservation.

1. UNCONSTRAINED KNOWLEDGE: You answer questions about ANY plant (native, agricultural, ornamental, houseplants, fruit trees, or exotics). Never state that a plant is out of scope. If a plant is non-native or invasive in India (e.g., Lantana camara, Prosopis juliflora, Parthenium), explain its ecological threat and suggest beneficial native Indian alternatives.
2. CURATED RECORD: When a specific Curated Plant Record is supplied, use it as your primary reference for that plant.
3. CITIZEN CONSERVATION & STEWARDSHIP: In every answer, provide practical, citizen-actionable conservation advice:
   • Root Zone Protection: Keep unpaved soil buffers around tree trunks, protect root zones from construction.
   • Living Soil & Water: Mulch with fallen dry leaves, avoid synthetic chemical pesticides, practice rainwater swales.
   • Native Propagation & Pollinators: Collect ripe fallen seeds ethically, plant native nectar flora for bees and butterflies.
4. Keep responses crisp, well-formatted with markdown headings and bullet points for field users."""


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
        plant_context: Optional[Dict[str, Any]] = None,
        chat_history: Optional[List[Any]] = None
    ) -> str:
        """
        Generates contextual response for AI Botanical Guide using Gemini API or fallback.
        """
        if settings.DEMO_MODE or not self.client:
            logger.info("Gemini Service running in DEMO_MODE / key missing fallback.")
            if plant_context:
                name = plant_context.get("common_name", "this plant")
                scic_name = plant_context.get("scientific_name", "")
                family = plant_context.get("family", "")
                importance = plant_context.get("ecological_importance", "")
                status = plant_context.get("conservation_status", "")
                actions = plant_context.get("conservation_actions", "")
                return (
                    f"**{name}** (*{scic_name}*) is a key native Indian species in the family **{family}**.\n\n"
                    f"**Ecological Significance**: {importance}\n\n"
                    f"**Conservation Status**: {status}\n\n"
                    f"🌱 **Actionable Conservation Steps**:\n"
                    f"• {actions}\n"
                    f"• Maintain unpaved root zones and mulch with organic leaf litter.\n"
                    f"• Avoid synthetic pesticides and protect native pollinator habitat."
                )
            return (
                "Hello! I am your AI Botanical & Conservation Guide specializing in India's native flora and ecological stewardship. "
                "Ask me about plant identification, soil health, propagation, or practical conservation actions across India."
            )

        # Build prompt and conversation context
        history_context = ""
        if chat_history:
            recent_turns = chat_history[-6:]
            for item in recent_turns:
                role = getattr(item, "role", "user")
                content = getattr(item, "content", "")
                history_context += f"{role.capitalize()}: {content}\n"



gemini_service = GeminiService()
