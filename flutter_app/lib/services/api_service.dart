import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/plant.dart';

class ApiService {
  static const String _cachedCatalogKey = 'cached_plant_catalog';

  // Fetch plant catalog with search support & offline caching fallback
  static Future<List<Plant>> getPlants({String? query}) async {
    final uri = Uri.parse(
      query != null && query.isNotEmpty
          ? '${ApiConfig.plantsUrl}?q=${Uri.encodeComponent(query)}'
          : ApiConfig.plantsUrl,
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        final plants = body.map((json) => Plant.fromJson(json)).toList();

        // Cache catalog if full list
        if (query == null || query.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cachedCatalogKey, response.body);
        }
        return plants;
      } else {
        throw Exception('Failed to load plants catalog (HTTP ${response.statusCode})');
      }
    } catch (e) {
      // Offline fallback: try reading cached catalog
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedCatalogKey);
      if (cachedJson != null) {
        final List<dynamic> body = jsonDecode(cachedJson);
        var plants = body.map((json) => Plant.fromJson(json)).toList();
        if (query != null && query.isNotEmpty) {
          final q = query.toLowerCase();
          plants = plants
              .where(
                (p) =>
                    p.commonName.toLowerCase().contains(q) ||
                    p.scientificName.toLowerCase().contains(q) ||
                    p.family.toLowerCase().contains(q),
              )
              .toList();
        }
        return plants;
      }
      rethrow;
    }
  }

  // Fetch single plant profile
  static Future<Plant> getPlantById(int id) async {
    final uri = Uri.parse(ApiConfig.plantDetailUrl(id));
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Plant.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Plant profile not found');
    }
  }
}
