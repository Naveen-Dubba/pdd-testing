/// Static holder for the currently logged-in user (your usual pattern).
class Session {
  static int? userId;
  static String? name;
  static String? email;
  static String? gender; // 'Male' / 'Female'
  static int? age;

  static bool get isLoggedIn => userId != null && email != null;

  static void set({
    required int userId,
    required String name,
    required String email,
    String? gender,
    int? age,
  }) {
    Session.userId = userId;
    Session.name = name;
    Session.email = email;
    Session.gender = gender;
    Session.age = age;
  }

  static void clear() {
    userId = null;
    name = null;
    email = null;
    gender = null;
    age = null;
  }
}
