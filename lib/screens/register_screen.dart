import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _age = TextEditingController();
  String _gender = 'Male';
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    final err = await AuthService.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      gender: _gender,
      age: int.tryParse(_age.text),
    );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BackgroundWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const KLogoMark(size: 72),
                const SizedBox(height: 24),
                KGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Join Vasthara AI', style: kDisplay(22, w: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        'A few details to personalize your AI styling',
                        style: kBody(13, color: kTextSecondary.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 24),
                      KTextField(controller: _name, hint: 'Full Name', icon: Icons.person_outline),
                      const SizedBox(height: 14),
                      KTextField(
                        controller: _email,
                        hint: 'Email Address',
                        icon: Icons.mail_outline,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      KTextField(
                        controller: _password,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: _obscure,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: kCardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kBorderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _gender,
                                  isExpanded: true,
                                  dropdownColor: kDeepBlack,
                                  icon: const Icon(Icons.expand_more, color: kElectricBlue),
                                  style: kBody(15, color: Colors.white),
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                                  ],
                                  onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: KTextField(
                              controller: _age,
                              hint: 'Age',
                              icon: Icons.cake_outlined,
                              type: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                      KPrimaryButton(label: 'Create Account', loading: _loading, onTap: _register),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: kBody(14, color: kTextSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
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
