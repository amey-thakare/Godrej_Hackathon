import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message.dart';
import '../models/plant.dart';
import 'api_service.dart';

class ChatService {
  static const String _systemInstruction =
      "You are an expert AI Botanical & Plant Conservation Guide specializing in Indian flora, "
      "Western Ghats biodiversity, Godrej green campuses, urban ecosystems, and global botany.\n\n"
      "CORE PRINCIPLES & SCOPE:\n"
      "1. UNCONSTRAINED BOTANICAL KNOWLEDGE: You enthusiastically answer questions about ANY plant species—"
      "native, endemic, agricultural crops, medicinal herbs, houseplants, flowering ornamentals, or exotic trees. "
      "Never refuse a question or state that a plant is out of scope. If a plant is non-native or invasive in India "
      "(e.g., Lantana camara, Prosopis juliflora, Parthenium hysterophorus), explain its ecological risks and suggest beneficial native Indian alternatives.\n"
      "2. CURATED CATALOGUE GROUNDING: When a Curated Plant Record is supplied, use it as your primary botanical authority for that species.\n"
      "3. ACTIONABLE CONSERVATION & STEWARDSHIP: In every answer, empower the user with practical, citizen-actionable conservation steps:\n"
      "   • Habitat & Root Care: Mulching, preserving tree root zones from concrete/paving, efficient watering.\n"
      "   • Organic Practices: Avoiding chemical pesticides/fertilizers, promoting native soil microbiology, companion planting.\n"
      "   • Native Propagation: Seed harvesting ethics, sapling nurture, native container planting for urban balconies.\n"
      "   • Wildlife & Pollinator Support: Welcoming bees, butterflies, sunbirds, and keystone frugivores.\n"
      "   • Community Action: Geo-tagging heritage trees, reporting invasive weed encroachments, community seed sharing.\n"
      "4. FORMATTING: Use crisp markdown with bold headings, bullet points, and scientific italic names (*Genus species*) for maximum readability.";

  static Future<String> sendMessage({
    required String message,
    int? plantId,
    List<ChatMessage>? history,
  }) async {
    // 1. Fetch plant context if plantId is provided
    Plant? plantContext;
    if (plantId != null) {
      try {
        plantContext = await ApiService.getPlantById(plantId);
      } catch (_) {}
    }

    // 2. Build multi-turn conversational contents
    final contents = <Map<String, dynamic>>[];

    // Add recent conversation history (up to last 6 messages)
    if (history != null && history.isNotEmpty) {
      final recent = history.length > 6 ? history.sublist(history.length - 6) : history;
      for (final m in recent) {
        // Skip default greeting if present
        if (m.text.startsWith('Hello! I am your')) continue;
        contents.add({
          "role": m.isUser ? "user" : "model",
          "parts": [
            {"text": m.text}
          ]
        });
      }
    }

    // Prepare current prompt with plant context if available
    String currentPrompt = message;
    if (plantContext != null) {
      currentPrompt = "[Active Curated Plant Record:\n"
          "- Common Name: ${plantContext.commonName}\n"
          "- Scientific Name: ${plantContext.scientificName}\n"
          "- Family: ${plantContext.family}\n"
          "- Native Region: ${plantContext.nativeRegion}\n"
          "- Conservation Status: ${plantContext.conservationStatus}\n"
          "- Ecological Importance: ${plantContext.ecologicalImportance}\n"
          "- Description: ${plantContext.description}\n"
          "- Threats: ${plantContext.threats}\n"
          "- Conservation Actions: ${plantContext.conservationActions}\n"
          "- Identification Features: ${plantContext.identificationFeatures}]\n\n"
          "User Question: $message";
    }

    contents.add({
      "role": "user",
      "parts": [
        {"text": currentPrompt}
      ]
    });

    final requestBody = {
      "system_instruction": {
        "parts": [
          {"text": _systemInstruction}
        ]
      },
      "contents": contents,
      "generationConfig": {
        "temperature": 0.4,
        "maxOutputTokens": 1024,
      }
    };

    // 3. Try models in cascade order
    for (final model in ApiConfig.fallbackGeminiModels) {
      try {
        final url = ApiConfig.getGeminiGenerateContentUrl(model);
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': ApiConfig.geminiApiKey,
              },
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 14));

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
        } else {
          debugPrint('Gemini Model $model returned status ${response.statusCode}');
        }
      } catch (err) {
        debugPrint('Gemini Model $model error: $err');
      }
    }

    // 4. Intelligent Botanical Fallback Engine (Offline)
    return await _generateOfflineBotanicalReply(message, plantContext);
  }

  static Future<String> _generateOfflineBotanicalReply(String message, Plant? plant) async {
    final msgLower = message.toLowerCase();

    // If no direct plant context, try to match any catalogue plant from the query
    Plant? resolvedPlant = plant;
    if (resolvedPlant == null) {
      try {
        final allPlants = await ApiService.getPlants();
        for (final p in allPlants) {
          final cName = p.commonName.toLowerCase();
          final sName = p.scientificName.toLowerCase();
          // Check common or scientific name matches
          final parts = cName.split(RegExp(r'[/,\-]'));
          final matchesCommon = parts.any((part) => msgLower.contains(part.trim().toLowerCase()));
          if (matchesCommon || msgLower.contains(sName) || msgLower.contains(p.family.toLowerCase())) {
            resolvedPlant = p;
            break;
          }
        }
      } catch (_) {}
    }

    // 1. Matched a plant from catalogue
    if (resolvedPlant != null) {
      final p = resolvedPlant;
      if (msgLower.contains('medic') ||
          msgLower.contains('ayurved') ||
          msgLower.contains('benefit') ||
          msgLower.contains('use') ||
          msgLower.contains('cure')) {
        return "🌿 **Medicinal & Traditional Value: ${p.commonName}** (*${p.scientificName}*)\n\n"
            "• **Botanical Family**: ${p.family}\n"
            "• **Key Traits**: ${p.identificationFeatures}\n"
            "• **Ecological Role**: ${p.ecologicalImportance}\n\n"
            "🛡️ **Stewardship & Sustainable Harvesting**:\n"
            "• Avoid debarking or harming living wild trees for medicinal parts.\n"
            "• Support ethical herbal cultivation and community botanical nurseries to reduce pressure on wild populations.";
      }

      if (msgLower.contains('threat') ||
          msgLower.contains('danger') ||
          msgLower.contains('conserve') ||
          msgLower.contains('protect') ||
          msgLower.contains('status') ||
          msgLower.contains('save') ||
          msgLower.contains('help')) {
        return "⚠️ **Conservation & Action Plan: ${p.commonName}** (*${p.scientificName}*)\n\n"
            "• **IUCN Red List Status**: ${p.conservationStatus}\n"
            "• **Major Threats**: ${p.threats}\n"
            "• **Native Habitat**: ${p.habitat}\n\n"
            "🌱 **How You Can Help Conserve This Species**:\n"
            "1. **Protect Root Zones**: Maintain an unpaved soil buffer of at least 2–3 meters around the tree trunk.\n"
            "2. **Organic Mulching**: Spread dried fallen leaves over root zones to conserve soil moisture and nurture beneficial fungi.\n"
            "3. **Native Propagation**: Collect ripe fallen seeds in the natural fruiting season, sow in organic loam, and distribute saplings to local parks or schools.\n"
            "4. **No Harmful Chemicals**: Avoid synthetic pesticides that harm pollinators visiting ${p.commonName} flowers.\n"
            "5. **Field Conservation Action**: ${p.conservationActions}";
      }

      if (msgLower.contains('identify') ||
          msgLower.contains('look like') ||
          msgLower.contains('spot') ||
          msgLower.contains('leaf') ||
          msgLower.contains('flower')) {
        return "🔍 **Field Identification Guide: ${p.commonName}** (*${p.scientificName}*)\n\n"
            "• **Family**: ${p.family}\n"
            "• **Identification Features**: ${p.identificationFeatures}\n"
            "• **Native Habitat**: ${p.habitat}\n"
            "• **Conservation Status**: ${p.conservationStatus}\n\n"
            "💡 *Field Tip*: Look for its characteristic leaves and bark texture. Take high-clarity photos of foliage and fruit to log on FloraDex!";
      }

      return "🌿 **${p.commonName}** (*${p.scientificName}*) — ${p.family}\n\n"
          "**Ecological Significance**:\n${p.ecologicalImportance}\n\n"
          "**Botanical Description**:\n${p.description}\n\n"
          "🌱 **Citizen Conservation Actions**:\n"
          "• ${p.conservationActions}\n"
          "• Maintain unpaved root zones and mulch with organic leaf litter.\n"
          "• Encourage local biodiversity by planting companion native flora.";
    }

    // 2. Topical Conservation & Ecological Queries
    if (msgLower.contains('conserve') ||
        msgLower.contains('protect') ||
        msgLower.contains('stewardship') ||
        msgLower.contains('save tree') ||
        msgLower.contains('save plant')) {
      return "🌱 **5 Pillars of Citizen Plant Conservation**\n\n"
          "1. **Root Zone Protection**: Tree roots require oxygen and water. Prevent concrete paving within 2–3 meters of tree bases.\n"
          "2. **Plant Native Species**: Native trees (Neem, Banyan, Jamun, Peepal, Ashoka) support 10x more native insect and bird species than exotic ornamentals.\n"
          "3. **Eliminate Synthetic Chemicals**: Chemical pesticides decimate native solitary bees and butterflies crucial for wild flora pollination.\n"
          "4. **Organic Mulching & Water-Wise Care**: Cover soil with dried leaves or woodchips to cut water evaporation by 70% and rebuild topsoil.\n"
          "5. **Citizen Science & Seed Banks**: Collect seeds of indigenous trees during fruiting seasons, propagate in organic nurseries, and geo-tag ancient heritage trees.";
    }

    if (msgLower.contains('balcony') ||
        msgLower.contains('pot') ||
        msgLower.contains('container') ||
        msgLower.contains('apartment') ||
        msgLower.contains('indoor') ||
        msgLower.contains('home garden')) {
      return "🪴 **Urban & Balcony Native Plant Conservation Guide**\n\n"
          "Even a small apartment balcony can become a vital green stepping stone for urban wildlife:\n\n"
          "• **Top Native Species for Pots**: Tulsi (*Ocimum tenuiflorum*), Adathoda (*Justicia adhatoda*), native Jasmine (*Jasminum sambac*), and Aloe vera.\n"
          "• **Potting Mix**: 40% garden red soil, 30% organic compost/vermicompost, 20% coco-peat, and 10% coarse sand.\n"
          "• **Pollinator Corner**: Add a shallow clay saucer with water and pebbles for visiting bees and sunbirds.\n"
          "• **Pest Care**: Spray diluted organic neem oil (5ml per liter of water with 2 drops of soap) instead of synthetic chemical sprays.";
    }

    if (msgLower.contains('soil') ||
        msgLower.contains('compost') ||
        msgLower.contains('fertiliz') ||
        msgLower.contains('manure')) {
      return "🍂 **Living Soil & Composting for Native Flora**\n\n"
          "Healthy soil is a living biome teeming with beneficial mycorrhizal fungi and earthworms:\n\n"
          "• **Leaf-Mold Composting**: Never burn dry autumn leaves! Pile them in a shaded corner to create dark, carbon-rich leaf mold that holds 5x its weight in water.\n"
          "• **Kitchen Waste Composting**: Mix nitrogen-rich greens (fruit peels, vegetable scraps) with brown carbon (dry leaves, shredded cardboard) in a 1:2 ratio.\n"
          "• **Mycorrhizal Inoculation**: Retain natural undisturbed soil around native trees to preserve fragile fungal networks that exchange nutrients with roots.";
    }

    if (msgLower.contains('water') ||
        msgLower.contains('drip') ||
        msgLower.contains('irrigation') ||
        msgLower.contains('drought')) {
      return "💧 **Water-Smart Botanical Conservation**\n\n"
          "• **Deep Root Watering**: Water deeply once or twice a week rather than light daily sprinkling. This trains tree roots to grow deep into groundwater tables.\n"
          "• **Mulch Armor**: A 3-inch layer of dried leaves or wood shavings reduces water evaporation drastically and regulates soil temperature.\n"
          "• **Rainwater Swales**: Dig shallow contoured basins around tree driplines to capture monsoon runoff and recharge groundwater aquifers.\n"
          "• **Timing**: Water in early mornings (before 8 AM) or evenings to minimize evaporative loss.";
    }

    if (msgLower.contains('pollinator') ||
        msgLower.contains('bee') ||
        msgLower.contains('butterfly') ||
        msgLower.contains('bird')) {
      return "🐝 **Attracting & Conserving Native Pollinators**\n\n"
          "Over 80% of flowering plants depend on wild pollinators like solitary bees, stingless bees, hawk moths, and butterflies:\n\n"
          "• **Host Plants for Caterpillars**: Plant native Citrus for Lime Butterflies, Calotropis (*Aak*) for Plain Tigers, and Aristolochia for Common Roses.\n"
          "• **Staggered Bloom Cycle**: Mix species that flower in different seasons so nectar is continuously available year-round.\n"
          "• **Mud Puddling Stations**: Provide a moist sand and salt dish where male butterflies can extract essential sodium and minerals.\n"
          "• **Zero Insecticides**: Never use neonics or broad-spectrum insecticides on flowering plants.";
    }

    if (msgLower.contains('invasive') ||
        msgLower.contains('lantana') ||
        msgLower.contains('weed') ||
        msgLower.contains('parthenium') ||
        msgLower.contains('prosopis')) {
      return "🚫 **Managing Invasive Plant Species in India**\n\n"
          "Invasive exotics choke native vegetation and degrade wildlife habitats across India:\n\n"
          "• **Key Invasives**: *Lantana camara*, *Prosopis juliflora* (Vilayati Kikar), *Parthenium hysterophorus* (Congress grass), and *Eichhornia crassipes* (Water Hyacinth).\n"
          "• **Safe Removal**: Manually uproot before seed heads mature. Avoid burning Lantana on-site as its smoke releases toxic triterpenoids.\n"
          "• **Ecological Replacement**: Immediately re-seed or plant fast-growing pioneer native species (such as *Cassia auriculata*, *Dodonaea viscosa*, or *Pongamia*) to prevent weed re-colonization.";
    }

    if (msgLower.contains('western ghats') ||
        msgLower.contains('mangrove') ||
        msgLower.contains('godrej') ||
        msgLower.contains('biodiversity hotspot')) {
      return "🏞️ **Western Ghats & Mangrove Conservation**\n\n"
          "• **Western Ghats**: One of the world's 8 'hottest biodiversity hotspots', holding over 5,000 vascular plant species with ~30% regional endemism.\n"
          "• **Godrej Mangrove Reserve**: The Vikhroli mangroves in Mumbai sequester enormous amounts of carbon, act as an irreplaceable storm-surge barrier, and purify estuarine waters.\n"
          "• **Keystone Trees**: *Ficus* species (Banyan, Peepal) provide emergency sustenance during lean seasons; *Avicennia marina* anchors tidal coastlines.";
    }

    // 3. Constructive general botanical guidance
    return "🌿 **AI Botanical & Conservation Guide**\n\n"
        "I am ready to assist with any botanical inquiry, plant care question, or conservation action!\n\n"
        "**Popular Topics to Explore**:\n"
        "• **Species Information**: Ask about Bougainvillea, Bamboo, Yellow Bells, Sunflower, Crape Jasmine, Rain Tree, or any campus plant.\n"
        "• **Conservation Practices**: Root zone protection, rainwater harvesting, seed collecting, and organic mulching.\n"
        "• **Urban Green Spaces**: Growing native potted plants on balconies and building wildlife corridors.\n"
        "• **Ecological Defense**: Managing invasive species (*Lantana*, *Parthenium*) and protecting ancient heritage trees.\n\n"
        "💬 *Feel free to ask any specific question about plants, habitats, or stewardship!*";
  }
}
