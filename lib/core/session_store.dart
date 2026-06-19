import 'package:shared_preferences/shared_preferences.dart';
import 'session.dart';

/// Persists the logged-in user so they stay signed in across app restarts.
class SessionStore {
  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (Session.userId != null) prefs.setInt('uid', Session.userId!);
    if (Session.name != null) prefs.setString('name', Session.name!);
    if (Session.email != null) prefs.setString('email', Session.email!);
    if (Session.gender != null) prefs.setString('gender', Session.gender!);
    if (Session.age != null) prefs.setInt('age', Session.age!);
  }

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('uid');
    final email = prefs.getString('email');
    if (uid != null && email != null) {
      Session.userId = uid;
      Session.name = prefs.getString('name');
      Session.email = email;
      Session.gender = prefs.getString('gender');
      Session.age = prefs.getInt('age');
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('gender');
    await prefs.remove('age');
  }
}
