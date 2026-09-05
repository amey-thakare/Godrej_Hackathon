import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/identification.dart';
import '../models/plant.dart';
import 'api_service.dart';

class IdentificationService {
  /// Downsamples large raw camera images to max 1024px to prevent upload timeouts
  static Future<Uint8List> _optimizeImage(Uint8List bytes) async {
    if (bytes.lengthInBytes <= 400 * 1024) {
      return bytes;
    }
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 1024,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint('Image downsampling error, using raw bytes: $e');
    }
    return bytes;
  }

  static Future<IdentificationResult> identifyPlantFromBytes(
    Uint8List rawBytes,
    String filename,
  ) async {
    // 1. Optimize image payload size
    final Uint8List imageBytes = await _optimizeImage(rawBytes);
    final isOptimizedPng = imageBytes != rawBytes;

    final mimeType = isOptimizedPng
        ? 'image/png'
        : filename.toLowerCase().endsWith('.png')
            ? 'image/png'
            : filename.toLowerCase().endsWith('.webp')
                ? 'image/webp'
                : 'image/jpeg';

    final base64Image = base64Encode(imageBytes);

    // 2. Try Backend API first
    try {
      debugPrint('=== IDENTIFICATION: Trying backend at ${ApiConfig.backendIdentifyUrl} ===');
      final backendUri = Uri.parse(ApiConfig.backendIdentifyUrl);
      final request = http.MultipartRequest('POST', backendUri);
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'plant_scan.jpg',
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== BACKEND RESPONSE: status=${response.statusCode} ===');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('=== BACKEND DATA: $data ===');
        if (data['success'] == true && data['identification'] != null) {
          final ident = data['identification'];
          final scicName = ident['scientific_name'] ?? 'Unknown';
          final commonName = ident['common_name'];
          final confVal = ident['confidence'];
          final confidence = (confVal is num) ? confVal.toDouble() : 0.85;

          debugPrint('=== BACKEND IDENTIFIED: scientific=$scicName common=$commonName conf=$confidence ===');

          final allPlants = await ApiService.getPlants();
          final matchedPlant = _matchCuratedPlant(scicName, commonName, allPlants);

          debugPrint('=== MATCHED PLANT: ${matchedPlant?.commonName ?? "NONE"} (id=${matchedPlant?.id}) ===');

          if (matchedPlant != null) {
            return IdentificationResult(
              success: true,
              identification: SpeciesIdentification(
                scientificName: matchedPlant.scientificName,
                commonName: matchedPlant.commonName,
                confidence: confidence,
                family: matchedPlant.family,
                description: matchedPlant.description,
                ecologicalImportance: matchedPlant.ecologicalImportance,
                details: matchedPlant.identificationFeatures,
              ),
              plant: matchedPlant,
              message: 'Identified via Backend AI',
            );
          } else {
             // Create generic plant if not in curated list
             final genericPlant = Plant(
              id: 99,
              scientificName: scicName,
              commonName: commonName ?? scicName,
              family: "Flora",
              nativeRegion: "Unknown",
              conservationStatus: "Not Evaluated",
              ecologicalImportance: "Native flora contributing to local ecosystem.",
              description: "Identified via Backend AI.",
              threats: "",
              conservationActions: "",
              habitat: "",
              identificationFeatures: "Identified via AI analysis.",
              imageUrl: "",
            );
            return IdentificationResult(
              success: true,
              identification: SpeciesIdentification(
                scientificName: scicName,
                commonName: commonName,
                confidence: confidence,
                family: "Flora",
                description: genericPlant.description,
                ecologicalImportance: genericPlant.ecologicalImportance,
                details: genericPlant.identificationFeatures,
              ),
              plant: genericPlant,
              message: 'Identified via Backend AI',
            );
          }
        }
      }
      debugPrint('Backend identify HTTP ${response.statusCode}: ${response.body.substring(0, math.min(200, response.body.length))}');
    } catch (e) {
      debugPrint('=== BACKEND FAILED: $e ===');
    }

    // 3. Fallback to direct Gemini Multimodal Vision API if backend is down
    try {
      debugPrint('=== IDENTIFICATION: Trying direct Gemini Vision API ===');
      debugPrint('=== API KEY (first 10 chars): ${ApiConfig.geminiApiKey.substring(0, math.min(10, ApiConfig.geminiApiKey.length))} ===');
      debugPrint('=== MIME TYPE: $mimeType, IMAGE SIZE: ${imageBytes.length} bytes ===');
      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "inline_data": {
                  "mime_type": mimeType,
                  "data": base64Image,
                }
              },
              {
                "text":
                    "You are a leading expert Indian botanist and field taxonomist specializing in native, cultivated, and wild flora of India (including trees, shrubs, climbers, herbs, and flowers).\n"
                    "Examine this plant image carefully: inspect leaf arrangement, venation, flower structure, bark texture, canopy, or fruit.\n"
                    "Identify the plant accurately. Return ONLY a valid JSON object matching this schema:\n"
                    "{\n"
                    "  \"scientific_name\": \"Latin binomial scientific name (e.g. Vanda coerulea, Azadirachta indica, Nelumbo nucifera, Lilium candidum, Rosa indica)\",\n"
                    "  \"common_name\": \"Primary common name (e.g. Blue Vanda Orchid, Neem, Lotus, Lily, Rose, Sunflower, Jasmine, Hibiscus)\",\n"
                    "  \"family\": \"Botanical Family (e.g. Orchidaceae, Meliaceae, Nelumbonaceae, Liliaceae, Rosaceae, Asteraceae)\",\n"
                    "  \"confidence\": 0.94,\n"
                    "  \"description\": \"Concise 2-3 sentence botanical summary highlighting characteristics\",\n"
                    "  \"ecological_importance\": \"Ecological role, habitat value, and benefits to native biodiversity\",\n"
                    "  \"details\": \"Key diagnostic morphological features observed in this specific image\"\n"
                    "}\n"
                    "If the image does not show a plant or is completely unidentifiable, set scientific_name to 'Unknown', common_name to null, and confidence to 0.15."
              }
            ]
          }
        ],
        "generationConfig": {
          "response_mime_type": "application/json"
        }
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
          .timeout(const Duration(seconds: 15));

      debugPrint('=== GEMINI DIRECT RESPONSE: status=${response.statusCode} ===');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            String text = parts[0]['text'] ?? '';
            debugPrint('=== GEMINI RAW TEXT: $text ===');
            text = text.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
            text = text.replaceAll(RegExp(r'^```\s*$', multiLine: true), '').trim();

            final jsonStart = text.indexOf('{');
            final jsonEnd = text.lastIndexOf('}');
            if (jsonStart != -1 && jsonEnd != -1) {
              final jsonClean = text.substring(jsonStart, jsonEnd + 1);
              final parsed = jsonDecode(jsonClean);
              debugPrint('=== GEMINI PARSED: scientific_name=${parsed["scientific_name"]} common_name=${parsed["common_name"]} ===');

              return _buildResultFromAIResponse(parsed, 'Gemini Vision AI (Direct)');
            }
          }
        }
      }
      debugPrint('=== GEMINI DIRECT FAILED: HTTP ${response.statusCode}: ${response.body.substring(0, math.min(300, response.body.length))} ===');
    } catch (e) {
      debugPrint('=== GEMINI VISION API ERROR: $e ===');
    }

    // 4. Final fallback: Honest "unable to identify" rather than a random guess
    debugPrint('=== IDENTIFICATION: ALL METHODS FAILED - returning unidentified ===');
    return _buildUnidentifiedResult();
  }


  /// Builds an IdentificationResult from any AI API response JSON
  static Future<IdentificationResult> _buildResultFromAIResponse(
    Map<String, dynamic> parsed,
    String source,
  ) async {
    final scientificName = parsed['scientific_name'] ?? 'Unknown';
    final commonName = parsed['common_name'] as String?;
    final family = parsed['family'] as String?;
    final description = parsed['description'] as String?;
    debugPrint('=== _buildResultFromAIResponse: sci=$scientificName common=$commonName source=$source ===');
    final ecologicalImportance = parsed['ecological_importance'] as String?;
    final details = parsed['details'] as String?;
    final confVal = parsed['confidence'];
    final confidence = (confVal is num) ? confVal.toDouble().clamp(0.0, 1.0) : 0.85;

    final allPlants = await ApiService.getPlants();
    debugPrint('=== _buildResult: allPlants count=${allPlants.length} ===');
    final matchedPlant = _matchCuratedPlant(scientificName, commonName, allPlants);
    debugPrint('=== _buildResult: matchedPlant=${matchedPlant?.commonName ?? "NONE"} id=${matchedPlant?.id} ===');

    final effectivePlant = matchedPlant ??
        Plant(
          id: 99,
          scientificName: scientificName != 'Unknown' ? scientificName : 'Unidentified Species',
          commonName: commonName ?? (scientificName != "Unknown" ? scientificName : "Unidentified Plant"),
          family: family ?? "Flora",
          nativeRegion: "Indian Subcontinent",
          conservationStatus: "Not Evaluated",
          ecologicalImportance: ecologicalImportance ?? "Native flora contributing to local ecosystem.",
          description: description ?? "Identified via $source.",
          threats: "Habitat loss and urbanization.",
          conservationActions: "Protect native ecosystems and biodiversity.",
          habitat: "Natural and cultivated landscapes",
          identificationFeatures: details ?? "Identified via $source analysis.",
          imageUrl: "",
        );

    return IdentificationResult(
      success: true,
      identification: SpeciesIdentification(
        scientificName: effectivePlant.scientificName,
        commonName: effectivePlant.commonName,
        confidence: confidence,
        family: effectivePlant.family,
        description: effectivePlant.description,
        ecologicalImportance: effectivePlant.ecologicalImportance,
        details: effectivePlant.identificationFeatures,
      ),
      plant: effectivePlant,
      message: source,
    );
  }

  /// Returns a realistic fallback when Gemini API hits Quota Limits
  static IdentificationResult _buildUnidentifiedResult() {
    final defaultPlant = Plant(
      id: 999,
      scientificName: 'Unknown Species',
      commonName: 'Identification Failed',
      family: 'Unknown',
      nativeRegion: 'Unknown',
      conservationStatus: 'Unknown',
      ecologicalImportance: 'API Rate Limit Reached',
      description: 'The AI identification service has reached its request limit. Please wait a minute and try again.',
      threats: '',
      conservationActions: '',
      habitat: '',
      identificationFeatures: '',
      imageUrl: '',
    );

    return IdentificationResult(
      success: false,
      identification: SpeciesIdentification(
        scientificName: defaultPlant.scientificName,
        commonName: defaultPlant.commonName,
        confidence: 0.0,
        family: defaultPlant.family,
        description: defaultPlant.description,
        ecologicalImportance: defaultPlant.ecologicalImportance,
        details: defaultPlant.identificationFeatures,
      ),
      plant: defaultPlant,
      message: 'API Quota Exceeded. Please try again later.',
    );
  }

  /// Comprehensive curated plant matcher with explicit checks for common flowers
  static Plant? _matchCuratedPlant(
    String scientificName,
    String? commonName,
    List<Plant> allPlants,
  ) {
    if (scientificName.toLowerCase() == 'unknown') return null;

    final scicLower = scientificName.toLowerCase();
    final commLower = (commonName ?? '').toLowerCase();

    // -- Explicit flower family matchers --

    // Lily / Liliaceae
    if (scicLower.contains('lilium') ||
        scicLower.contains('lily') ||
        scicLower.contains('hemerocallis') ||
        commLower.contains('lily') ||
        commLower.contains('lili')) {
      for (final plant in allPlants) {
        if (plant.family.toLowerCase().contains('lili') ||
            plant.commonName.toLowerCase().contains('lily') ||
            plant.scientificName.toLowerCase().contains('lilium')) {
          return plant;
        }
      }
    }

    // Rose / Rosaceae
    if (scicLower.contains('rosa') ||
        commLower.contains('rose') ||
        commLower.contains('gulab')) {
      for (final plant in allPlants) {
        if (plant.family.toLowerCase().contains('rosaceae') ||
            plant.commonName.toLowerCase().contains('rose') ||
            plant.scientificName.toLowerCase().contains('rosa')) {
          return plant;
        }
      }
    }

    // Sunflower / Asteraceae
    if (scicLower.contains('helianthus') ||
        commLower.contains('sunflower') ||
        commLower.contains('surajmukhi')) {
      for (final plant in allPlants) {
        if (plant.commonName.toLowerCase().contains('sunflower') ||
            plant.scientificName.toLowerCase().contains('helianthus')) {
          return plant;
        }
      }
    }

    // Jasmine / Oleaceae
    if (scicLower.contains('jasminum') ||
        commLower.contains('jasmine') ||
        commLower.contains('mogra') ||
        commLower.contains('chameli')) {
      for (final plant in allPlants) {
        if (plant.commonName.toLowerCase().contains('jasmine') ||
            plant.commonName.toLowerCase().contains('mogra') ||
            plant.scientificName.toLowerCase().contains('jasminum')) {
          return plant;
        }
      }
    }

    // Hibiscus / Malvaceae
    if (scicLower.contains('hibiscus') ||
        commLower.contains('hibiscus') ||
        commLower.contains('gudhal')) {
      for (final plant in allPlants) {
        if (plant.commonName.toLowerCase().contains('hibiscus') ||
            plant.commonName.toLowerCase().contains('gudhal') ||
            plant.scientificName.toLowerCase().contains('hibiscus')) {
          return plant;
        }
      }
    }

    // Lotus / Nelumbonaceae
    if (scicLower.contains('nelumbo') ||
        scicLower.contains('lotus') ||
        commLower.contains('lotus') ||
        commLower.contains('kamal')) {
      for (final plant in allPlants) {
        if (plant.family.toLowerCase().contains('nelumbon') ||
            plant.commonName.toLowerCase().contains('lotus') ||
            plant.scientificName.toLowerCase().contains('nelumbo')) {
          return plant;
        }
      }
    }

    // Orchid / Orchidaceae
    if (scicLower.contains('orchid') ||
        scicLower.contains('vanda') ||
        scicLower.contains('phalaenopsis') ||
        scicLower.contains('dendrobium') ||
        scicLower.contains('paphiopedilum') ||
        commLower.contains('orchid')) {
      for (final plant in allPlants) {
        if (plant.family.toLowerCase().contains('orchid') ||
            plant.commonName.toLowerCase().contains('orchid') ||
            plant.scientificName.toLowerCase().contains('vanda')) {
          return plant;
        }
      }
    }

    // Passion flower / Passifloraceae
    if (scicLower.contains('passiflora') || commLower.contains('passion flower') || commLower.contains('krishna kamal')) {
      for (final plant in allPlants) {
        if (plant.family.toLowerCase().contains('passifloraceae') ||
            plant.commonName.toLowerCase().contains('passion flower') ||
            plant.scientificName.toLowerCase().contains('passiflora')) {
          return plant;
        }
      }
    }

    // Marigold
    if (scicLower.contains('tagetes') ||
        commLower.contains('marigold') ||
        commLower.contains('genda')) {
      for (final plant in allPlants) {
        if (plant.commonName.toLowerCase().contains('marigold') ||
            plant.scientificName.toLowerCase().contains('tagetes')) {
          return plant;
        }
      }
    }

    // -- Generic scientific name matching --
    final scicWords = scientificName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final commClean = (commonName ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s/]'), '')
        .trim();

    for (final plant in allPlants) {
      final pScic = plant.scientificName.toLowerCase();
      final pScicWords = pScic
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();

      if (scicWords.length >= 2 && pScicWords.length >= 2) {
        if (scicWords[0] == pScicWords[0] && scicWords[1] == pScicWords[1]) {
          return plant;
        }
      }

      // Genus-level match (first word of scientific name)
      if (scicWords.isNotEmpty && pScicWords.isNotEmpty && scicWords[0].length >= 4) {
        if (scicWords[0] == pScicWords[0]) {
          return plant;
        }
      }

      if (commClean.isNotEmpty && commClean.length >= 3) {
        final aliases = plant.commonName
            .toLowerCase()
            .split('/')
            .map((s) => s.trim())
            .toList();

        for (final alias in aliases) {
          if (alias.isEmpty) continue;
          if (commClean == alias || commClean.contains(alias) || alias.contains(commClean)) {
            if (alias != 'tree' && alias != 'plant' && commClean != 'tree' && commClean != 'plant') {
              return plant;
            }
          }
        }
      }
    }
    return null;
  }
}
