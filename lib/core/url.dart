/// Central backend URL management (your usual url.dart pattern).
class Api {
  // 🔗 Set this to your Railway deployment URL.
  static const String baseUrl = "https://web-production-3b600.up.railway.app";

  // Auth
  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";
  static const String currentUser = "$baseUrl/get_current_user";
  static const String logout = "$baseUrl/logout";
  static const String userUpdate = "$baseUrl/user/update";

  // Analyses (history)
  static const String analysis = "$baseUrl/analysis";
  static String analysesByUser(int userId) => "$baseUrl/analysis/$userId";
  static String deleteAnalysis(int id) => "$baseUrl/analysis/$id";
  static String clearAnalyses(int userId) => "$baseUrl/analysis/clear/$userId";

  // Misc
  static String dashboard(int userId) => "$baseUrl/dashboard/$userId";
}
