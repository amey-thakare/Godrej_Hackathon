import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';

class PlantRecognitionResult {
  final String scientificName;
  final String commonName;
  final String plantFamily;

  PlantRecognitionResult({
    required this.scientificName,
    required this.commonName,
    required this.plantFamily,
  });

  factory PlantRecognitionResult.fromJson(Map<String, dynamic> json) {
    return PlantRecognitionResult(
      scientificName: json['Scientific Name'] ?? 'Unknown',
      commonName: json['Common Name'] ?? 'Unknown',
      plantFamily: json['Plant Family'] ?? 'Unknown',
    );
  }
}

class PlantRecognitionService {
  static Future<PlantRecognitionResult?> identifyPlant(Uint8List imageBytes) async {
    try {
      final apiKey = ApiConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        throw Exception('Gemini API key is not configured.');
      }

      final schema = Schema.object(
        properties: {
          'Scientific Name': Schema.string(description: 'The scientific name of the plant.'),
          'Common Name': Schema.string(description: 'The common name of the plant.'),
          'Plant Family': Schema.string(description: 'The botanical family of the plant.'),
        },
        requiredProperties: ['Scientific Name', 'Common Name', 'Plant Family'],
      );

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: schema,
        ),
      );

      final prompt = TextPart(
        'You are an expert botanist. Analyze this image and identify the plant. '
        'Focus on identifying native plant species of India. '
        'Provide the result strictly following the JSON schema.',
      );
      
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      if (response.text != null) {
        final jsonResponse = jsonDecode(response.text!);
        return PlantRecognitionResult.fromJson(jsonResponse);
      }
    } catch (e) {
      debugPrint('PlantRecognitionService Error: $e');
      return null;
    }
    return null;
  }
}
