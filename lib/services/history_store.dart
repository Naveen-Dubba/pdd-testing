import '../core/session.dart';
import '../models/analysis_result.dart';
import '../models/history_entry.dart';
import 'api_service.dart';

/// History now lives on the backend (analyses table), keyed by the logged-in user.
class HistoryStore {
  static Future<void> add(AnalysisResult result, String bestColor) async {
    final uid = Session.userId;
    if (uid == null) return;
    try {
      await ApiService.addAnalysis(userId: uid, result: result, bestColor: bestColor);
    } catch (_) {/* don't block the UI if save fails */}
  }

  static Future<List<HistoryEntry>> all() async {
    final uid = Session.userId;
    if (uid == null) return [];
    try {
      return await ApiService.getAnalyses(uid);
    } catch (_) {
      return [];
    }
  }

  static Future<void> delete(int id) async {
    try {
      await ApiService.deleteAnalysis(id);
    } catch (_) {}
  }

  static Future<void> clear() async {
    final uid = Session.userId;
    if (uid == null) return;
    try {
      await ApiService.clearAnalyses(uid);
    } catch (_) {}
  }
}
