import 'plant.dart';

class SpeciesIdentification {
  final String scientificName;
  final String? commonName;
  final double confidence;

  SpeciesIdentification({
    required this.scientificName,
    this.commonName,
    required this.confidence,
  });

  factory SpeciesIdentification.fromJson(Map<String, dynamic> json) {
    return SpeciesIdentification(
      scientificName: json['scientific_name'] ?? 'Unknown species',
      commonName: json['common_name'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get confidenceLevelText {
    if (confidence >= 0.75) return 'High confidence';
    if (confidence >= 0.50) return 'Moderate confidence';
    return 'Low confidence';
  }
}

class IdentificationResult {
  final bool success;
  final SpeciesIdentification identification;
  final Plant? plant;
  final String? message;

  IdentificationResult({
    required this.success,
    required this.identification,
    this.plant,
    this.message,
  });

  factory IdentificationResult.fromJson(Map<String, dynamic> json) {
    return IdentificationResult(
      success: json['success'] ?? false,
      identification: SpeciesIdentification.fromJson(
        json['identification'] ?? {},
      ),
      plant: json['plant'] != null ? Plant.fromJson(json['plant']) : null,
      message: json['message'],
    );
  }
}
