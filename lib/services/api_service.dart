import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/url.dart';
import '../models/analysis_result.dart';
import '../models/history_entry.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const _headers = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 20);

  // ── AUTH ──────────────────────────────────────────────
  /// Returns the user map on success, throws ApiException on failure.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? gender,
    int? age,
  }) async {
    final res = await http
        .post(Uri.parse(Api.register),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'gender': gender,
              'age': age,
            }))
        .timeout(_timeout);
    final body = _decode(res);
    if (res.statusCode == 201) return Map<String, dynamic>.from(body['user']);
    throw ApiException(body['error']?.toString() ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http
        .post(Uri.parse(Api.login),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}))
        .timeout(_timeout);
    final body = _decode(res);
    if (res.statusCode == 200) return Map<String, dynamic>.from(body['user']);
    throw ApiException(body['error']?.toString() ?? 'Login failed');
  }

  static Future<void> logout() async {
    try {
      await http.post(Uri.parse(Api.logout), headers: _headers).timeout(_timeout);
    } catch (_) {/* ignore network errors on logout */}
  }

  static Future<Map<String, dynamic>> updateUser({
    required String email,
    String? name,
    String? gender,
    int? age,
  }) async {
    final res = await http
        .put(Uri.parse(Api.userUpdate),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              if (name != null) 'name': name,
              if (gender != null) 'gender': gender,
              if (age != null) 'age': age,
            }))
        .timeout(_timeout);
    final body = _decode(res);
    if (res.statusCode == 200) return Map<String, dynamic>.from(body['user']);
    throw ApiException(body['error']?.toString() ?? 'Update failed');
  }

  // ── ANALYSES (history) ────────────────────────────────
  static Future<void> addAnalysis({
    required int userId,
    required AnalysisResult result,
    required String bestColor,
  }) async {
    await http
        .post(Uri.parse(Api.analysis),
            headers: _headers,
            body: jsonEncode({
              'user_id': userId,
              'gender': result.gender,
              'face_shape': result.faceShape,
              'skin_tone': result.skinTone,
              'body_type': result.bodyType,
              'size_suggestion': result.sizeSuggestion,
              'style_personality': result.stylePersonality,
              'best_color': bestColor,
            }))
        .timeout(_timeout);
  }

  static Future<List<HistoryEntry>> getAnalyses(int userId) async {
    final res = await http
        .get(Uri.parse(Api.analysesByUser(userId)), headers: _headers)
        .timeout(_timeout);
    if (res.statusCode != 200) return [];
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => HistoryEntry.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> deleteAnalysis(int id) async {
    await http
        .delete(Uri.parse(Api.deleteAnalysis(id)), headers: _headers)
        .timeout(_timeout);
  }

  static Future<void> clearAnalyses(int userId) async {
    await http
        .delete(Uri.parse(Api.clearAnalyses(userId)), headers: _headers)
        .timeout(_timeout);
  }

  // ── helpers ───────────────────────────────────────────
  static Map<String, dynamic> _decode(http.Response res) {
    try {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    } catch (_) {
      throw ApiException('Server error (${res.statusCode}). Please try again.');
    }
  }
}
