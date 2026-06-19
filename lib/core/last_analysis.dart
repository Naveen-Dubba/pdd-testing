import '../models/analysis_result.dart';

/// Keeps the most recent analysis in memory so the dress-match checker
/// can compare a dress against the user's detected skin tone / gender.
class LastAnalysis {
  static AnalysisResult? result;
}
