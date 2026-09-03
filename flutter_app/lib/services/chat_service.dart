import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatService {
  static Future<String> sendMessage({
    required String message,
    int? plantId,
  }) async {
    final uri = Uri.parse(ApiConfig.chatUrl);
    final payload = {
      'message': message,
      if (plantId != null) 'plant_id': plantId,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'No response received from Botanical Guide.';
      } else {
        throw Exception('Botanical Guide is temporarily unavailable.');
      }
    } catch (e) {
      throw Exception('Botanical Guide is temporarily unavailable. Please check your connection.');
    }
  }
}
