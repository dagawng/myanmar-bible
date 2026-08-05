import 'package:flutter/material.dart';

class AppColors {
  // 🍷 Modern Elegant Warm Palette
  static const Color warmBackground = Color(0xFFFAF7F2); // Soft warm cream
  static const Color warmSurface = Color(0xFFFFFFFF);    // Pure white cards
  static const Color warmSurfaceContainer = Color(0xFFF4EBE1); // Warm almond container
  static const Color warmPrimary = Color(0xFF7A2828);    // Rich mahogany / burgundy
  static const Color warmSecondary = Color(0xFF9E4747);  // Warm deep rose
  static const Color warmOnSurface = Color(0xFF2C221E);  // Deep espresso text
  static const Color warmOnSurfaceVariant = Color(0xFF6B5E57); // Warm taupe text

  // Dark Mode Night Reading Palette
  static const Color darkBackground = Color(0xFF1A1614); // Deep charcoal espresso
  static const Color darkSurface = Color(0xFF26201D);    // Warm dark card surface
  static const Color darkSurfaceContainer = Color(0xFF332A27); // Darker taupe
  static const Color darkPrimary = Color(0xFFE08E8E);    // Warm soft rose accent
  static const Color darkSecondary = Color(0xFFB37474);  // Muted rose secondary
  static const Color darkOnSurface = Color(0xFFEAE0D5);  // Light cream text
  static const Color darkOnSurfaceVariant = Color(0xFFB5A8A0); // Soft grey-brown text
  static const Color darkPrimaryContainer = Color(0xFF4A2B2B); // Deep burgundy container
  static const Color darkOnPrimaryContainer = Color(0xFFFFD9D9); // Light pink text

  static ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: warmPrimary,
    brightness: Brightness.light,
  ).copyWith(
    surface: warmBackground,
    surfaceContainerLow: warmSurface,
    surfaceContainerHighest: warmSurfaceContainer,
    onSurface: warmOnSurface,
    onSurfaceVariant: warmOnSurfaceVariant,
    primary: warmPrimary,
    primaryContainer: warmSurfaceContainer,
    onPrimaryContainer: warmPrimary,
    secondary: warmSecondary,
  );

  static ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: darkPrimary,
    brightness: Brightness.dark,
  ).copyWith(
    surface: darkBackground,
    surfaceContainerLow: darkSurface,
    surfaceContainerHighest: darkSurfaceContainer,
    onSurface: darkOnSurface,
    onSurfaceVariant: darkOnSurfaceVariant,
    primary: darkPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
  );
}
