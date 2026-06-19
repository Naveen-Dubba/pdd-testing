/// Result of the AI face analysis (matches the result-card fields).
class AnalysisResult {
  String gender; // 'Male' / 'Female'
  String faceShape; // Oval, Round, Square...
  String skinTone; // Fair, Light, Medium, Dark, Deep
  String bodyType; // Pear / A-Shape...
  String sizeSuggestion; // Small (S)...
  String stylePersonality; // Bohemian Rhapsody...

  AnalysisResult({
    required this.gender,
    required this.faceShape,
    required this.skinTone,
    required this.bodyType,
    required this.sizeSuggestion,
    required this.stylePersonality,
  });

  /// Parse the JSON object returned by the Groq vision model.
  /// Tolerant of missing keys and odd casing.
  factory AnalysisResult.fromJson(Map<String, dynamic> j) {
    String pick(List<String> keys, String fallback) {
      for (final k in keys) {
        final v = j[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
      }
      return fallback;
    }

    return AnalysisResult(
      gender: pick(['gender', 'detected_gender'], 'Male'),
      faceShape: pick(['face_shape', 'faceShape'], 'Oval'),
      skinTone: pick(['skin_tone', 'skinTone'], 'Medium'),
      bodyType: pick(['body_type', 'bodyType'], 'Rectangle'),
      sizeSuggestion: pick(['size', 'size_suggestion', 'sizeSuggestion'], 'Medium (M)'),
      stylePersonality: pick(['style_personality', 'style', 'stylePersonality'], 'Classic'),
    );
  }

  /// A safe default if parsing completely fails.
  factory AnalysisResult.fallback() => AnalysisResult(
        gender: 'Male',
        faceShape: 'Oval',
        skinTone: 'Medium',
        bodyType: 'Rectangle',
        sizeSuggestion: 'Medium (M)',
        stylePersonality: 'Classic',
      );

  /// gender string normalized for search queries: 'men' / 'women'
  String get genderForSearch =>
      gender.toLowerCase().startsWith('f') ? 'women' : 'men';

  Map<String, dynamic> toMap() => {
        'gender': gender,
        'face_shape': faceShape,
        'skin_tone': skinTone,
        'body_type': bodyType,
        'size': sizeSuggestion,
        'style_personality': stylePersonality,
      };
}
