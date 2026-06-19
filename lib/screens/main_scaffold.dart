import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'home_screen.dart';
import 'capture_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';

/// App shell with a bottom navigation bar.
/// Tabs map to the features we actually have:
/// Home · Analyze (camera) · Stylist (chatbot) · Profile
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  final _tabs = const [
    HomeScreen(),
    CaptureScreen(),
    ChatbotScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content to flow behind bottom navigation
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        child: KGlassCard(
          borderRadius: 24,
          padding: EdgeInsets.zero,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: kElectricBlue,
            unselectedItemColor: kTextSecondary.withOpacity(0.5),
            selectedLabelStyle: kDisplay(11, w: FontWeight.w700, color: kElectricBlue),
            unselectedLabelStyle: kBody(11, color: kTextSecondary.withOpacity(0.5)),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home, color: kElectricBlue),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                activeIcon: Icon(Icons.camera_alt, color: kElectricBlue),
                label: 'Analyze',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome, color: kElectricBlue),
                label: 'Stylist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person, color: kElectricBlue),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
