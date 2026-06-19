import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/session.dart';
import '../services/weather_service.dart';
import '../services/notify_service.dart';
import 'capture_screen.dart';
import 'match_checker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherInfo? _weather;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final info = await WeatherService.getDressSuggestion();
    if (!mounted) return;
    setState(() {
      _weather = info;
      _weatherLoading = false;
    });
    // fire a one-time outfit tip notification
    if (info != null) {
      NotifyService.show(
        'Today\'s outfit tip ${info.emoji}',
        '${info.tempC.round()}°C in ${info.city}. ${info.suggestion}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = Session.name ?? 'there';
    return Scaffold(
      body: BackgroundWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const KLogoMark(size: 38),
                  Text(
                    'VASTHARA AI',
                    style: kDisplay(18, w: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Hello, $name',
                style: kDisplay(28, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Ready to discover your perfect style match?',
                style: kBody(14, color: kTextSecondary),
              ),
              const SizedBox(height: 22),

              // weather outfit banner
              if (_weatherLoading)
                _weatherSkeleton()
              else if (_weather != null)
                _weatherBanner(_weather!),

              const SizedBox(height: 20),
              _heroCard(context),

              const SizedBox(height: 20),
              _matchCard(context),

              const SizedBox(height: 28),
              Text(
                'Quick Actions',
                style: kDisplay(18, w: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _actionTile(
                      icon: Icons.chat_bubble_outline,
                      title: 'Style Chat',
                      subtitle: 'Ask the AI stylist',
                      onTap: () => Navigator.pushNamed(context, '/chatbot'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _actionTile(
                      icon: Icons.history,
                      title: 'History',
                      subtitle: 'Past analyses',
                      onTap: () => Navigator.pushNamed(context, '/history'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weatherBanner(WeatherInfo w) {
    return KGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(w.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${w.tempC.round()}°C · ${w.city}',
                  style: kBody(13, color: kElectricBlue, w: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  w.suggestion,
                  style: kBody(13, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherSkeleton() {
    return const KGlassCard(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: kElectricBlue),
          ),
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            kRoyalPurple.withOpacity(0.45),
            Colors.black.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: kRoyalPurple.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kRoyalPurple.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kGold.withOpacity(0.2), width: 1),
                      ),
                      child: const Icon(Icons.face_retouching_natural, color: kGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI PERSONAL STYLIST',
                      style: kDisplay(14, color: kGold, w: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Analyze Your Face',
                  style: kDisplay(24, color: Colors.white, w: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get your personalized colors, sizing, and style recommendations, then shop them instantly.',
                  style: kBody(14, color: kTextSecondary),
                ),
                const SizedBox(height: 24),
                KPrimaryButton(
                  label: 'Start AI Analysis',
                  icon: Icons.camera_alt_outlined,
                  isGold: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CaptureScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _matchCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MatchCheckerScreen()),
      ),
      child: KGlassCard(
        padding: const EdgeInsets.all(18),
        borderColor: kBorderColor,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kElectricBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kElectricBlue.withOpacity(0.2)),
              ),
              child: const Icon(Icons.checkroom_outlined, color: kElectricBlue, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Will It Match Me?',
                    style: kDisplay(16, w: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Scan any garment and check compatibility',
                    style: kBody(12, color: kTextSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextSecondary),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: KGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kElectricBlue, size: 26),
            const SizedBox(height: 16),
            Text(
              title,
              style: kDisplay(16, w: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: kBody(12, color: kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
