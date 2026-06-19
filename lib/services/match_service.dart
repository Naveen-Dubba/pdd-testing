import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/secrets.dart';

class DressMatch {
  final String verdict;
  final int score;
  final String reason;
  final String tips;
  DressMatch({
    required this.verdict,
    required this.score,
    required this.reason,
    required this.tips,
  });

  factory DressMatch.fromJson(Map<String, dynamic> j) => DressMatch(
        verdict: (j['verdict'] ?? 'Works').toString(),
        score: int.tryParse('${j['score']}') ?? 60,
        reason: (j['reason'] ?? '').toString(),
        tips: (j['tips'] ?? '').toString(),
      );
}

class MatchService {
  static const String _url =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _visionModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';

  /// Accepts raw image bytes — works on Web, Android, iOS, and desktop.
  Future<DressMatch> check(
    Uint8List imageBytes, {
    String? skinTone,
    String? gender,
  }) async {
    if (imageBytes.length > 4 * 1024 * 1024) {
      throw Exception('Image too large. Please use one under 4 MB.');
    }

    final b64 = base64Encode(imageBytes);
    const mime = 'image/jpeg';

    final context = [
      if (skinTone != null && skinTone.isNotEmpty) 'skin tone: $skinTone',
      if (gender != null && gender.isNotEmpty) 'gender: $gender',
    ].join(', ');

    final userText = '''
Look at this clothing item. Considering the person's ${context.isEmpty ? 'general styling' : context},
judge whether this garment's colour and style would suit them.
Return ONLY this JSON object, nothing else:
{
  "verdict": "Great match | Works | Not ideal",
  "score": 0-100,
  "reason": "one short sentence why",
  "tips": "one short styling tip or a better colour suggestion"
}
''';

    final res = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Authorization': 'Bearer ${Secrets.groqChatKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': _visionModel,
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are an expert fashion stylist. You always answer with only a valid JSON object.'
              },
              {
                'role': 'user',
                'content': [
                  {'type': 'text', 'text': userText},
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:$mime;base64,$b64'}
                  }
                ]
              }
            ],
            'temperature': 0.4,
            'max_completion_tokens': 400,
            'stream': false,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Request timed out. Try again.'),
        );

    if (res.statusCode == 401) {
      throw Exception('Invalid API key in secrets.dart');
    }
    if (res.statusCode != 200) {
      throw Exception('Check failed (${res.statusCode}). Try again.');
    }

    final data = jsonDecode(res.body);
    final content =
        data['choices']?[0]?['message']?['content']?.toString() ?? '';
    return DressMatch.fromJson(_extractJson(content));
  }

  Map<String, dynamic> _extractJson(String raw) {
    var s = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final a = s.indexOf('{'), b = s.lastIndexOf('}');
    if (a != -1 && b != -1 && b > a) s = s.substring(a, b + 1);
    try {
      return Map<String, dynamic>.from(jsonDecode(s));
    } catch (_) {
      return {};
    }
  }
}
