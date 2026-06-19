import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final err = await AuthService.login(_email.text, _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const KLogoMark(size: 80),
                const SizedBox(height: 24),
                Text(
                  'VASTHARA AI',
                  style: kDisplay(32, w: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Luxury Personalized Styling',
                  style: kBody(15, color: kTextSecondary),
                ),
                const SizedBox(height: 36),
                KGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: kDisplay(22, w: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to access your digital wardrobe',
                        style: kBody(13, color: kTextSecondary.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 24),
                      KTextField(
                        controller: _email,
                        hint: 'Email Address',
                        icon: Icons.mail_outline,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      KTextField(
                        controller: _password,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: _obscure,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          child: Text(
                            _obscure ? 'Show password' : 'Hide password',
                            style: kBody(13, color: kElectricBlue, w: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      KPrimaryButton(
                        label: 'Sign In',
                        loading: _loading,
                        onTap: _login,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: kBody(14, color: kTextSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'Register',
                        style: kBody(14, color: kGold, w: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
