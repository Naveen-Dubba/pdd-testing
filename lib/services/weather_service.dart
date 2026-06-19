import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../core/secrets.dart';

class WeatherInfo {
  final double tempC;
  final String condition;
  final String city;
  final String suggestion;
  final String emoji;
  WeatherInfo({
    required this.tempC,
    required this.condition,
    required this.city,
    required this.suggestion,
    required this.emoji,
  });
}

class WeatherService {
  static const String _owmKey = Secrets.owmKey;

  /// Gets the user's location, current weather, and an outfit suggestion.
  /// Returns null if location/weather is unavailable (handled gracefully).
  static Future<WeatherInfo?> getDressSuggestion() async {
    try {
      final pos = await _position();
      if (pos == null) return null;
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=metric&appid=$_owmKey';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body);
      final temp = (j['main']?['temp'] as num?)?.toDouble() ?? 0;
      final cond = (j['weather']?[0]?['main'] ?? '').toString();
      final city = (j['name'] ?? '').toString();
      final s = _suggest(temp, cond);
      return WeatherInfo(
        tempC: temp,
        condition: cond,
        city: city,
        suggestion: s.$1,
        emoji: s.$2,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Position?> _position() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
  }

  /// (suggestion, emoji)
  static (String, String) _suggest(double t, String cond) {
    final c = cond.toLowerCase();
    final rainy = c.contains('rain') || c.contains('drizzle') || c.contains('thunder');
    if (rainy) {
      return ('Rain about — carry a jacket or umbrella and skip suede or delicate fabrics.', '🌧️');
    }
    if (t >= 30) {
      return ('It\'s hot today — light cottons, half-sleeves and breathable fabrics in lighter colours.', '☀️');
    }
    if (t >= 22) {
      return ('Pleasant weather — a shirt or a light layer will be comfortable.', '🌤️');
    }
    if (t >= 14) {
      return ('A bit cool — add a light jacket or sweater over your outfit.', '🧥');
    }
    return ('Cold out — layer up with a coat or sweater to stay warm.', '❄️');
  }
}
