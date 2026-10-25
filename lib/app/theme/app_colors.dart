import 'package:flutter/material.dart';

class AppColors {
  // Brand Gradients & Accents
  static const Color primaryOrange = Color(0xFFFF6D00);
  static const Color primaryOrangeLight = Color(0xFFFF9E40);
  static const Color primaryOrangeDark = Color(0xFFE65100);
  static const Color accentOrange = Color(0xFFFF7A00);
  static const Color gradientStart = Color(0xFFFF8500);
  static const Color gradientEnd = Color(0xFFFF3B00);

  // Backgrounds & Warm Tones
  static const Color bgWarmAmber = Color(0xFFFEF3E8);
  static const Color bgWarmGlow = Color(0xFFFBE6D3);
  static const Color bgDark = Color(0xFF0F172A);

  // Glassmorphism Values
  static const Color glassWhite = Color(0x38FFFFFF);
  static const Color glassWhiteCard = Color(0x2EFFFFFF);
  static const Color glassWhiteCardStrong = Color(0x45FFFFFF);
  static const Color glassWhiteInput = Color(0x28FFFFFF);
  static const Color glassWhiteLight = Color(0x52FFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);
  static const Color glassBorderLight = Color(0x80FFFFFF);
  static const Color glassBorderSubtle = Color(0x33FFFFFF);
  static const Color glassBorderFocus = Color(0xFFFF9E40);

  // Text Colors
  static const Color textLight = Colors.white;
  static const Color textLightSub = Color(0xFFE2E8F0);
  static const Color textLightMuted = Color(0xFFCBD5E1);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textDarkSub = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Functional Palette (Matching Dashboard Grid & Badges)
  static const Color metricBlue = Color(0xFF0284C7);
  static const Color metricBlueBg = Color(0x1F0284C7);
  static const Color metricOrange = Color(0xFFEA580C);
  static const Color metricOrangeBg = Color(0x1FEA580C);
  static const Color metricGreen = Color(0xFF16A34A);
  static const Color metricGreenBg = Color(0x1F16A34A);
  static const Color metricPurple = Color(0xFF9333EA);
  static const Color metricPurpleBg = Color(0x1F9333EA);

  // Alert & Warning
  static const Color alertPink = Color(0xFFF43F5E);
  static const Color alertPinkBg = Color(0x26F43F5E);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningAmber = Color(0xFFF59E0B);

  // Gradients
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8C00), Color(0xFFFF3D00)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF9100), Color(0xFFFF4800)],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x14FFFFFF)],
  );

  static const LinearGradient warmBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF8A00),
      Color(0xFFFFA23A),
      Color(0xFFFE8C00),
      Color(0xFFFF6D00),
    ],
  );
}
