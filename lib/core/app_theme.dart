import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ── Vasthara AI Premium Brand Palette ───────────────────────────────────────
const Color kDeepBlack = Color(0xFF0B0B0B);
const Color kRoyalPurple = Color(0xFF7C4DFF);
const Color kElectricBlue = Color(0xFF00E5FF);
const Color kGold = Color(0xFFFFD700);
const Color kGoldDark = Color(0xFFC8A24C);
const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFFB0B3B8);
const Color kCardBg = Color(0x0CFFFFFF); // ~5% opacity for glassmorphism
const Color kBorderColor = Color(0x1AFFFFFF); // ~10% opacity white border

/// ── Shared Text Styles ─────────────────────────────────────────────────────
TextStyle kDisplay(double size, {Color color = kTextPrimary, FontWeight w = FontWeight.w700}) =>
    GoogleFonts.outfit(fontSize: size, fontWeight: w, color: color, height: 1.2, letterSpacing: -0.5);

TextStyle kBody(double size, {Color color = kTextSecondary, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: color, height: 1.4);

/// ── Global Theme Definition ────────────────────────────────────────────────
ThemeData kAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: kDeepBlack,
    primaryColor: kRoyalPurple,
    colorScheme: const ColorScheme.dark(
      primary: kRoyalPurple,
      secondary: kElectricBlue,
      surface: kDeepBlack,
      onSurface: kTextPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: kTextPrimary),
      titleTextStyle: kDisplay(20, w: FontWeight.w600),
    ),
    useMaterial3: true,
  );
}

/// ── Cinematic Background Wrapper ───────────────────────────────────────────
class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDeepBlack,
      child: Stack(
        children: [
          // Purple ambient light top left
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kRoyalPurple.withValues(alpha: 0.18),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Blue ambient light bottom right
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kElectricBlue.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Subtle center purple glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kRoyalPurple.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

/// ── Premium Glassmorphic Card ──────────────────────────────────────────────
class KGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Color? bgColor;

  const KGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding,
    this.borderColor,
    this.boxShadow,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? kCardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? kBorderColor,
          width: 1.2,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// ── Premium Button (Gradients / Glassmorphism) ──────────────────────────────
class KPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  final bool isGold;
  final Color? bg;
  final Color? fg;

  const KPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.icon,
    this.isGold = false,
    this.bg,
    this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isGold
        ? const LinearGradient(
            colors: [Color(0xFFF9D423), Color(0xFFFF4E50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [kRoyalPurple, Color(0xFF9F75FF), kElectricBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: onTap == null ? null : gradient,
        color: onTap == null ? Colors.white10 : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: onTap == null
            ? null
            : [
                BoxShadow(
                  color: (isGold ? Color(0xFFFF4E50) : kRoyalPurple).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: fg ?? Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                    Text(label, style: kDisplay(16, color: fg ?? Colors.white, w: FontWeight.w600)),
                  ],
                ),
              ),
      ),
    );
  }
}

/// ── Premium Glassmorphic Text Field ──────────────────────────────────────────
class KTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType type;

  const KTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kBorderColor,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: type,
            style: kBody(15, color: kTextPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: kBody(15, color: kTextSecondary.withValues(alpha: 0.6)),
              prefixIcon: Icon(icon, color: kElectricBlue, size: 20),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

/// ── Premium Glowing Brand Logo ─────────────────────────────────────────────
class KLogoMark extends StatelessWidget {
  final double size;
  const KLogoMark({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [kRoyalPurple, kElectricBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kRoyalPurple.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: kElectricBlue.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: size * 0.45,
        ),
      ),
    );
  }
}
