import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';
import '../models/plant.dart';

class BotanicalChatService {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  BotanicalChatService(Plant plant) {
    final apiKey = ApiConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Gemini API key is missing.');
    }

    final systemPrompt = '''
You are an expert Virtual Botanist and Conservation Guide.
You are currently assisting a user in the field. They have just scanned and identified the following plant via AR:
- Scientific Name: ${plant.scientificName}
- Common Name: ${plant.commonName}
- Family: ${plant.family}
- Native Region: ${plant.nativeRegion}
- Ecological Role: ${plant.ecologicalImportance}
- Conservation Status: ${plant.conservationStatus}

Use this context to answer their questions. Be concise, engaging, and focus on ecology and conservation.
''';

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
    );
    
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'I have no words right now.';
    } catch (e) {
      return 'Sorry, I am having trouble connecting to my botanical database. ($e)';
    }
  }
}
