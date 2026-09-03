class Plant {
  final int id;
  final String scientificName;
  final String commonName;
  final String family;
  final String nativeRegion;
  final String conservationStatus;
  final String ecologicalImportance;
  final String description;
  final String threats;
  final String conservationActions;
  final String habitat;
  final String identificationFeatures;
  final String? imageUrl;
  final String? plantnetSpeciesName;

  Plant({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.family,
    required this.nativeRegion,
    required this.conservationStatus,
    required this.ecologicalImportance,
    required this.description,
    required this.threats,
    required this.conservationActions,
    required this.habitat,
    required this.identificationFeatures,
    this.imageUrl,
    this.plantnetSpeciesName,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as int,
      scientificName: json['scientific_name'] ?? '',
      commonName: json['common_name'] ?? '',
      family: json['family'] ?? '',
      nativeRegion: json['native_region'] ?? '',
      conservationStatus: json['conservation_status'] ?? '',
      ecologicalImportance: json['ecological_importance'] ?? '',
      description: json['description'] ?? '',
      threats: json['threats'] ?? '',
      conservationActions: json['conservation_actions'] ?? '',
      habitat: json['habitat'] ?? '',
      identificationFeatures: json['identification_features'] ?? '',
      imageUrl: json['image_url'],
      plantnetSpeciesName: json['plantnet_species_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scientific_name': scientificName,
      'common_name': commonName,
      'family': family,
      'native_region': nativeRegion,
      'conservation_status': conservationStatus,
      'ecological_importance': ecologicalImportance,
      'description': description,
      'threats': threats,
      'conservation_actions': conservationActions,
      'habitat': habitat,
      'identification_features': identificationFeatures,
      'image_url': imageUrl,
      'plantnet_species_name': plantnetSpeciesName,
    };
  }
}
