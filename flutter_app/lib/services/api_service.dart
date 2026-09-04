import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../config/api_config.dart';
import '../models/plant.dart';

class ApiService {
  static List<Plant>? _cachedPlants;

  // Load and cache all plants from the local bundled JSON asset
  static Future<List<Plant>> _loadAllPlants() async {
    if (_cachedPlants != null && _cachedPlants!.isNotEmpty) {
      return _cachedPlants!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString(ApiConfig.localPlantsJsonPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedPlants = jsonList.map((j) => Plant.fromJson(j)).toList();
      return _cachedPlants!;
    } catch (e) {
      throw Exception('Failed to load local plant database: $e');
    }
  }

  // Fetch plant catalog with local search and filtering
  static Future<List<Plant>> getPlants({String? query}) async {
    final allPlants = await _loadAllPlants();

    if (query == null || query.trim().isEmpty) {
      return allPlants;
    }

    final q = query.trim().toLowerCase();
    return allPlants.where((p) {
      return p.commonName.toLowerCase().contains(q) ||
          p.scientificName.toLowerCase().contains(q) ||
          p.family.toLowerCase().contains(q) ||
          p.nativeRegion.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  // Fetch single plant profile by ID
  static Future<Plant> getPlantById(int id) async {
    final allPlants = await _loadAllPlants();
    final plant = allPlants.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Plant profile not found for id $id'),
    );
    return plant;
  }
}
