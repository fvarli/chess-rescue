import 'package:flutter/material.dart';

// D4 Convergence palette. Source: docs/visual-direction.md.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF0D0E12);
  static const Color surface = Color(0xFF161821);
  static const Color surface2 = Color(0xFF1D2030);

  static const Color text = Color(0xFFEAEAF2);
  static const Color textDim = Color(0x8CEAEAF2); // 55% alpha
  static const Color textMuted = Color(0x52EAEAF2); // 32% alpha
  static const Color hairline = Color(0x12FFFFFF); // 7% white

  // V1 polish: slight contrast nudge for the checker — lighter squares a hair
  // brighter, darker squares a hair deeper — to deepen the surface read once
  // the grain overlay and inner vignette are layered on top.
  static const Color boardLight = Color(0xFF3E4250);
  static const Color boardDark = Color(0xFF161823);
  static const Color gridLine = Color(0x0AFFFFFF); // 4% white

  static const Color danger = Color(0xFFFF5A4C);
  static const Color rescue = Color(0xFF5EE2C0);
  static const Color accent = Color(0xFF8AA1FF);

  // Atmosphere / surfaces
  static const Color backdropDanger = Color(0xFF1A1C28); // radial gradient core
  static const Color backdropRescue = Color(0xFF0E2A23); // radial gradient core
  static const Color onRescue = Color(0xFF062019); // text on the mint footer
  static const Color pillFill = Color(0xB30D0E12); // status pill background
  static const Color boardShadow = Color(0x8C000000); // board drop shadow
}

class AppText {
  AppText._();

  static const String _displayFamily = 'Inter';
  static const String _monoFamily = 'monospace';

  static const TextStyle headline = TextStyle(
    fontFamily: _displayFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22, // ~ -0.01em at 22px
    color: AppColors.text,
    height: 1.15,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _displayFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textDim,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _displayFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.52, // ~ 0.04em
    color: AppColors.text,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.47, // ~ 0.14em at 10.5px
    color: AppColors.text,
    height: 1.0,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      surface: AppColors.bg,
      primary: AppColors.accent,
      secondary: AppColors.rescue,
      error: AppColors.danger,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}
