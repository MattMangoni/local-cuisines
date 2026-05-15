import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFF000000);
  static const surface = Color(0xFF1C1C1E);
  static const surfaceVariant = Color(0xFF2C2C2E);
  static const divider = Color(0xFF38383A);
  static const accent = Color(0xFFFF6B3D);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8E8E93);
  static const illustration = Color(0xFF3A3A3C);
}

class AppRadius {
  const AppRadius._();

  static const card = 16.0;
  static const pill = 28.0;
}

class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.divider,
    error: AppColors.accent,
    onError: AppColors.textPrimary,
  );

  const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.1,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.15,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    iconTheme: const IconThemeData(color: AppColors.accent),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
      space: 0.5,
    ),
  );
}
