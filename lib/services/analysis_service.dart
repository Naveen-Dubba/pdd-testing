import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/secrets.dart';
import '../models/analysis_result.dart';

/// Sends the captured face photo bytes to Groq's vision model and parses a
/// structured style analysis out of it.
class AnalysisService {
  static const String _url =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _visionModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';

  /// Accepts raw image bytes (works on Web, Android, iOS, Windows).
  Future<AnalysisResult> analyzeFace(Uint8List imageBytes) async {
    if (imageBytes.length > 4 * 1024 * 1024) {
      throw Exception('Image too large. Please use an image under 4 MB.');
    }

    final base64Image = base64Encode(imageBytes);
    // default to jpeg — Groq accepts both jpeg and png
    const mimeType = 'image/jpeg';

    const systemPrompt = '''
You are an expert AI personal stylist and image analyst. You look at a single
face photo and estimate styling attributes. You ALWAYS respond with ONLY a
valid JSON object and nothing else — no markdown, no commentary.
''';

    const userText = '''
Analyze the person in this photo and return ONLY this JSON object:
{
  "gender": "Male | Female",
  "face_shape": "Oval | Round | Square | Heart | Oblong | Diamond",
  "skin_tone": "Fair | Light | Medium | Dark | Deep",
  "body_type": "best visual estimate e.g. Pear / A-Shape, Rectangle, Inverted Triangle",
  "size": "best estimate e.g. Small (S), Medium (M), Large (L)",
  "style_personality": "a short evocative style label e.g. Bohemian Rhapsody, Classic Elegance, Urban Minimal"
}
Respond with the JSON object only.
''';

    final response = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Authorization': 'Bearer ${Secrets.groqAnalysisKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _visionModel,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {
                'role': 'user',
                'content': [
                  {'type': 'text', 'text': userText},
                  {
                    'type': 'image_url',
                    'image_url': {
                      'url': 'data:$mimeType;base64,$base64Image'
                    }
                  }
                ]
              }
            ],
            'temperature': 0.4,
            'max_completion_tokens': 512,
            'top_p': 0.9,
            'stream': false,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception(
              'Request timed out. Check your internet and try again.'),
        );

    if (response.statusCode == 401) {
      throw Exception(
          'Invalid API key. Check the analysis key in analysis_service.dart');
    }
    if (response.statusCode != 200) {
      throw Exception(
          'Analysis failed (${response.statusCode}). Please try again.');
    }

    final data = jsonDecode(response.body);
    final content = data['choices']?[0]?['message']?['content'];
    if (content == null) throw Exception('No analysis returned. Please retry.');

    final parsed = _extractJson(content.toString());
    return AnalysisResult.fromJson(parsed);
  }

  Map<String, dynamic> _extractJson(String raw) {
    var s = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      s = s.substring(start, end + 1);
    }
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
