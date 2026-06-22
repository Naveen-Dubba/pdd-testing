import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';
import '../services/history_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BackgroundWrapper(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
          children: [
            _tile(Icons.person_outline, 'Account', 'View your profile',
                () => Navigator.pushNamed(context, '/profile')),
            _tile(Icons.history, 'Analysis History', 'Your saved scans',
                () => Navigator.pushNamed(context, '/history')),
            _tile(Icons.delete_outline, 'Clear History', 'Remove all saved scans',
                () => _clearHistory(context)),
            _tile(Icons.key, 'API Key Settings', 'Configure your custom Groq API key',
                () => _editApiKey(context)),
            _tile(Icons.info_outline, 'About', 'Vasthara AI v1.0',
                () => _about(context)),
            const SizedBox(height: 16),
            _logoutTile(context),
          ],
        ),
      ),
    );
  }

  Future<void> _clearHistory(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kDeepBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear history?', style: kDisplay(18, color: Colors.white)),
        content: Text('This removes all saved analyses on this device.',
            style: kBody(14, color: kTextSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: kBody(14, color: kTextSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Clear',
                  style: kBody(14, color: const Color(0xFFFF5252), w: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true) {
      await HistoryStore.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('History cleared.')));
      }
    }
  }

  Future<void> _editApiKey(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentKey = prefs.getString('groq_api_key') ?? '';
    final controller = TextEditingController(text: currentKey);

    if (!context.mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kDeepBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Groq API Key', style: kDisplay(18, color: Colors.white)),
        content: TextField(
          controller: controller,
          style: kBody(14, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'gsk_...',
            hintStyle: kBody(14, color: kTextSecondary),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: kBody(14, color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text('Save', style: kBody(14, color: kElectricBlue, w: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result.trim().isEmpty) {
        await prefs.remove('groq_api_key');
      } else {
        await prefs.setString('groq_api_key', result.trim());
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Key updated successfully.')),
        );
      }
    }
  }

  void _about(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vasthara AI',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Your Personal AI Fashion Stylist',
      children: [
        const SizedBox(height: 12),
        Text('Capture your face, get your best colors and outfit ideas, '
            'then shop them on Amazon & Flipkart.',
            style: kBody(13, color: kTextSecondary)),
      ],
    );
  }

  Widget _tile(IconData icon, String title, String sub, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: KGlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: kElectricBlue),
          title: Text(title, style: kBody(15, w: FontWeight.w600, color: Colors.white)),
          subtitle: Text(sub, style: kBody(12, color: kTextSecondary)),
          trailing: const Icon(Icons.chevron_right, color: kTextSecondary),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _logoutTile(BuildContext context) {
    return KGlassCard(
      padding: EdgeInsets.zero,
      borderColor: const Color(0x33FF5252),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Color(0xFFFF5252)),
        title: Text('Log out',
            style: kBody(15, color: const Color(0xFFFF5252), w: FontWeight.w600)),
        onTap: () async {
          await AuthService.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }
        },
      ),
    );
  }
}
