import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/identification.dart';

class IdentificationService {
  static Future<IdentificationResult> identifyPlantFromBytes(
    Uint8List imageBytes,
    String filename,
  ) async {
    final uri = Uri.parse(ApiConfig.identifyUrl);
    final request = http.MultipartRequest('POST', uri);

    final lowerName = filename.toLowerCase();
    MediaType mediaType = MediaType('image', 'jpeg');
    if (lowerName.endsWith('.png')) {
      mediaType = MediaType('image', 'png');
    } else if (lowerName.endsWith('.webp')) {
      mediaType = MediaType('image', 'webp');
    }

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: filename.isNotEmpty ? filename : 'plant.jpg',
      contentType: mediaType,
    );
    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 25),
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return IdentificationResult.fromJson(jsonMap);
      } else {
        final Map<String, dynamic> errorMap = jsonDecode(response.body);
        final errorMsg = errorMap['detail'] ?? 'Identification server error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Unable to identify the plant right now: ${e.toString()}');
    }
  }
}
