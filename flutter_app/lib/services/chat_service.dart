import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/plant.dart';
import 'api_service.dart';

class ChatService {
  static const String _systemInstruction =
      "You are an expert botanical and conservation AI guide specializing in India's native, endemic, and cultivated flora, "
      "with specific focus on the Godrej campus and Western Ghats biodiversity.\n\n"
      "Your purpose is to provide rich, scientifically accurate, and engaging answers about plants, ecosystems, distribution across India, "
      "ecological roles, and conservation.\n"
      "1. When a specific Curated Plant Record is supplied, use it as your primary reference for that plant.\n"
      "2. For general botanical, agricultural, geographic, or ecological questions about any plant, use your deep botanical knowledge to provide complete, informative, and helpful answers.\n"
      "3. Promote responsible plant observation, ecological restoration, and environmental stewardship.\n"
      "4. Keep responses concise, well-formatted with markdown headings/bullet points, and easy to read for field users.";

  static Future<String> sendMessage({
    required String message,
    int? plantId,
  }) async {
    // 1. Fetch plant context if plantId is provided
    Plant? plantContext;
    if (plantId != null) {
      try {
        plantContext = await ApiService.getPlantById(plantId);
      } catch (_) {}
    }

    // 2. Try Direct Gemini API call
    try {
      String fullPrompt = "User Question: $message\n\n";
      if (plantContext != null) {
        fullPrompt += "Curated Plant Record:\n"
            "- Common Name: ${plantContext.commonName}\n"
            "- Scientific Name: ${plantContext.scientificName}\n"
            "- Family: ${plantContext.family}\n"
            "- Native Region: ${plantContext.nativeRegion}\n"
            "- Conservation Status: ${plantContext.conservationStatus}\n"
            "- Ecological Importance: ${plantContext.ecologicalImportance}\n"
            "- Description: ${plantContext.description}\n"
            "- Threats: ${plantContext.threats}\n"
            "- Conservation Actions: ${plantContext.conservationActions}\n"
            "- Identification Features: ${plantContext.identificationFeatures}\n";
      }

      final requestBody = {
        "system_instruction": {
          "parts": [
            {"text": _systemInstruction}
          ]
        },
        "contents": [
          {
            "parts": [
              {"text": fullPrompt}
            ]
          }
        ]
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.geminiGenerateContentUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': ApiConfig.geminiApiKey,
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final String reply = parts[0]['text'] ?? '';
            if (reply.trim().isNotEmpty) {
              return reply.trim();
            }
          }
        }
      }
      debugPrint('Gemini Chat HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('Gemini Chat online call failed, using intelligent offline guide: $e');
    }

    // 3. Intelligent Botanical Fallback Engine (Offline)
    return _generateOfflineBotanicalReply(message, plantContext);
  }

  static String _generateOfflineBotanicalReply(String message, Plant? plant) {
    final msgLower = message.toLowerCase();

    if (plant != null) {
      if (msgLower.contains('medic') ||
          msgLower.contains('ayurved') ||
          msgLower.contains('benefit') ||
          msgLower.contains('use') ||
          msgLower.contains('cure')) {
        return "🌿 **Medicinal & Traditional Profile: ${plant.commonName}** (*${plant.scientificName}*)\n\n"
            "• **Family**: ${plant.family}\n"
            "• **Botanical Traits**: ${plant.identificationFeatures}\n"
            "• **Ecological Significance**: ${plant.ecologicalImportance}\n\n"
            "💡 *Field Note*: Traditional Indian knowledge systems (such as Ayurveda) document ${plant.commonName} extensively. "
            "Always promote sustainable harvesting and conservation of native wild specimens.";
      }

      if (msgLower.contains('threat') ||
          msgLower.contains('danger') ||
          msgLower.contains('conserve') ||
          msgLower.contains('protect') ||
          msgLower.contains('status')) {
        return "⚠️ **Conservation Status: ${plant.commonName}** (*${plant.scientificName}*)\n\n"
            "• **IUCN Status**: ${plant.conservationStatus}\n"
            "• **Key Threats**: ${plant.threats}\n"
            "• **Field Conservation Actions**: ${plant.conservationActions}\n\n"
            "🌱 *Stewardship*: Establishing native buffer zones and seed propagation helps reinforce local canopy density.";
      }

      return "🌿 **${plant.commonName}** (*${plant.scientificName}*)\n\n"
          "• **Family**: ${plant.family}\n"
          "• **Native Region**: ${plant.nativeRegion}\n"
          "• **Conservation Status**: ${plant.conservationStatus}\n\n"
          "**Ecological Importance**:\n${plant.ecologicalImportance}\n\n"
          "**Description**:\n${plant.description}\n\n"
          "**Conservation Actions**:\n${plant.conservationActions}";
    }

    if (msgLower.contains('neem')) {
      return "🌿 **Neem (*Azadirachta indica*)** — Meliaceae\n\n"
          "• **Role**: Premier natural biopesticide and air purifying canopy. The active compound azadirachtin deters over 200 insect pests.\n"
          "• **Ayurveda**: Prized for antibacterial, blood-purifying, and dental hygiene qualities.\n"
          "• **Conservation**: Protect wild bark from over-harvesting; ideal boundary planting for campus bio-filtration.";
    }

    if (msgLower.contains('banyan')) {
      return "🌳 **Banyan Tree (*Ficus benghalensis*)** — Moraceae\n\n"
          "• **Keystone Species**: Produces year-round fig crops that sustain over 100 species of birds, fruit bats, and insects.\n"
          "• **Stewardship**: Protect aerial drop roots and avoid paving over root zones.";
    }

    if (msgLower.contains('western ghats') || msgLower.contains('biodiversity')) {
      return "🏞️ **Western Ghats Biodiversity Hotspot**:\n\n"
          "The Western Ghats harbors over 5,000 flowering plant species, nearly 30% of which are strictly endemic to the region.\n\n"
          "• **Keystone Trees**: Ficus species (Banyan, Peepal) anchor avian food webs.\n"
          "• **Threatened Gems**: Ashoka (*Saraca asoca*) and Sandalwood (*Santalum album*) are high-priority conservation species.\n"
          "• **Soil Restorers**: Karanja (*Pongamia pinnata*) restores nitrogen in degraded soils.";
    }

    return "🌿 **AI Botanical Field Guide**\n\n"
        "I can provide complete scientific insights on:\n"
        "• **Native Species**: Neem, Banyan, Jamun, Peepal, Ashoka, Mahua, Sandalwood\n"
        "• **Medicinal & Traditional Properties**: Active compounds, Ayurvedic value\n"
        "• **Ecosystem Roles**: Pollinators, keystone figs, nitrogen fixers\n"
        "• **Conservation & Stewardship**: IUCN status, habitat restoration\n\n"
        "Ask me about any plant or ecological topic!";
  }
}
