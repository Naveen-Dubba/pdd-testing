import 'analysis_result.dart';

/// One saved analysis from the backend.
class HistoryEntry {
  final int? id;          // server id (for delete)
  final AnalysisResult result;
  final String bestColor;
  final String dateLabel; // pre-formatted by the backend

  HistoryEntry({
    required this.id,
    required this.result,
    required this.bestColor,
    required this.dateLabel,
  });

  /// Builds from the flat JSON the backend returns.
  factory HistoryEntry.fromApi(Map<String, dynamic> j) => HistoryEntry(
        id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}'),
        result: AnalysisResult.fromJson(j), // reads gender, face_shape, skin_tone, etc.
        bestColor: (j['best_color'] ?? '').toString(),
        dateLabel: (j['created_at'] ?? '').toString(),
      );
}
