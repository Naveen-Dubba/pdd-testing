import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/session.dart';
import '../core/session_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await SessionStore.restore();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Session.isLoggedIn ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWrapper(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const KLogoMark(size: 110),
              const SizedBox(height: 32),
              Text(
                'VASTHARA AI',
                style: kDisplay(38, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Your Personal AI Fashion Stylist',
                style: kBody(15, color: kTextSecondary, w: FontWeight.w500),
              ),
              const Spacer(),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(kElectricBlue),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Initializing Luxury Studio…',
                style: kBody(13, color: kTextSecondary.withOpacity(0.7)),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
