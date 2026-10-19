import 'package:flutter/material.dart';

abstract final class SeduhColors {
  static const ink = Color(0xFF30251F);
  static const muted = Color(0xFF786A5F);
  static const paper = Color(0xFFFAF7F0);
  static const line = Color(0xFFE6DFD2);
  static const coffee = Color(0xFF6D4935);
  static const sage = Color(0xFF3F5847);
  static const pale = Color(0xFFF0E9DD);
}

final seduhTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'DMSans',
  scaffoldBackgroundColor: SeduhColors.paper,
  colorScheme: ColorScheme.fromSeed(
    seedColor: SeduhColors.coffee,
    primary: SeduhColors.coffee,
    secondary: SeduhColors.sage,
    surface: SeduhColors.paper,
    onSurface: SeduhColors.ink,
  ),
  dividerColor: SeduhColors.line,
  appBarTheme: const AppBarTheme(
    backgroundColor: SeduhColors.paper,
    foregroundColor: SeduhColors.ink,
    surfaceTintColor: Colors.transparent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: SeduhColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: SeduhColors.line),
    ),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: SeduhColors.paper,
    indicatorColor: SeduhColors.pale,
    height: 72,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.transparent,
    selectedColor: SeduhColors.coffee,
    side: const BorderSide(color: SeduhColors.line),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);

TextStyle editorial(double size) => TextStyle(
  fontFamily: 'Fraunces',
  fontSize: size,
  height: 1.13,
  color: SeduhColors.ink,
  letterSpacing: -0.8,
);
