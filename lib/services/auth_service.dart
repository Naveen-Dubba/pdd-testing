import '../core/session.dart';
import '../core/session_store.dart';
import 'api_service.dart';

/// Real auth wired to the Flask backend.
class AuthService {
  /// Returns null on success, or an error message string on failure.
  static Future<String?> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Please enter email and password.';
    }
    try {
      final user = await ApiService.login(email.trim(), password);
      Session.set(
        userId: user['id'],
        name: user['name'] ?? '',
        email: user['email'] ?? email.trim(),
        gender: user['gender'],
        age: user['age'],
      );
      await SessionStore.save();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not connect. Check your internet and try again.';
    }
  }

  static Future<String?> register({
    required String name,
    required String email,
    required String password,
    String? gender,
    int? age,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return 'Please fill all required fields.';
    }
    if (password.length < 4) return 'Password must be at least 4 characters.';
    try {
      final user = await ApiService.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
        gender: gender,
        age: age,
      );
      Session.set(
        userId: user['id'],
        name: user['name'] ?? name.trim(),
        email: user['email'] ?? email.trim(),
        gender: user['gender'] ?? gender,
        age: user['age'] ?? age,
      );
      await SessionStore.save();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not connect. Check your internet and try again.';
    }
  }

  static Future<void> logout() async {
    await ApiService.logout();
    Session.clear();
    await SessionStore.clear();
  }
}
