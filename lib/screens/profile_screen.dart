import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/session.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = Session.name ?? 'Guest';
    final email = Session.email ?? '—';
    final gender = Session.gender ?? '—';
    final age = Session.age?.toString() ?? '—';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: BackgroundWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [kRoyalPurple, kElectricBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kRoyalPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: kDisplay(44, color: Colors.white, w: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: kDisplay(26, w: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: kBody(14, color: kTextSecondary),
              ),
              const SizedBox(height: 32),
              _infoCard([
                _info(Icons.person_outline, 'Gender', gender),
                _info(Icons.cake_outlined, 'Age', age),
                _info(Icons.mail_outline, 'Email', email),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return KGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, color: kTextSecondary.withOpacity(0.15)),
          ]
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: kElectricBlue, size: 22),
          const SizedBox(width: 14),
          Text(label, style: kBody(14, color: kTextSecondary)),
          const Spacer(),
          Text(
            value,
            style: kBody(15, w: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
