import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'services/notify_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/chatbot_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotifyService.init();
  runApp(const AiVastraApp());
}

class AiVastraApp extends StatelessWidget {
  const AiVastraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ai Vastra',
      debugShowCheckedModeBanner: false,
      theme: kAppTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const MainScaffold(),
        '/chatbot': (_) => const ChatbotScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/history': (_) => const HistoryScreen(),
      },
      // screens that need constructor arguments are pushed directly via
      // MaterialPageRoute (capture/preview/analyzing/result/colors/shop).
    );
  }
}
