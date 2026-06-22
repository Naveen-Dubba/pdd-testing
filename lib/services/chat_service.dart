import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/secrets.dart';
import '../models/chat_message.dart';

/// Fashion / styling chatbot powered by Groq's text model.
/// Uses a separate key from AnalysisService to avoid shared rate limits.
class ChatService {
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _textModel = 'llama-3.1-8b-instant';

  static const String _systemPrompt = '''
You are VASTRA AI, a friendly expert fashion stylist. You help people with
outfit ideas, colour pairing, what to wear for occasions (weddings, office,
casual, parties), body-type styling tips, and shopping suggestions for the
Indian market (brands available on Amazon and Flipkart).

Keep answers practical, warm, and concise. Use short paragraphs or simple
points. When suggesting items, mention colours and occasions clearly.
''';

  /// Sends the recent conversation for context and returns the assistant reply.
  Future<String> send(List<ChatMessage> history, String userMessage) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      ...history.reversed.take(8).toList().reversed.map((m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.text,
          }),
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('groq_api_key') ?? Secrets.groqChatKey;

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _textModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'top_p': 0.9,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content']?.toString().trim() ??
            'Sorry, I could not generate a reply. Please try again.';
      } else if (response.statusCode == 429) {
        return "I'm getting a lot of requests right now. Please try again in a moment.";
      } else {
        return "Something went wrong (${response.statusCode}). Please try again.";
      }
    } catch (e) {
      return "I couldn't connect right now. Please check your internet and try again.";
    }
  }
}
