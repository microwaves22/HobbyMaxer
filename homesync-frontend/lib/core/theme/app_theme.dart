import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// HomeSync light theme (default) and dark theme (Teen Mode).
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.sage,
      onPrimary: AppColors.white,
      secondary: AppColors.sageDark,
      surface: AppColors.white,
      error: AppColors.error,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: _textTheme(AppColors.ink, AppColors.muted),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.button,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sageDark,
          textStyle: AppTypography.button,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.sageLight,
        labelStyle: AppTypography.bodySmall.copyWith(color: AppColors.ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppColors.sageLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sageLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sageLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sage, width: 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.sage,
          selectedForegroundColor: AppColors.white,
          foregroundColor: AppColors.sageDark,
          textStyle: AppTypography.label,
        ),
      ),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.sageGlow,
      onPrimary: AppColors.night,
      secondary: AppColors.sage,
      surface: AppColors.nightSurface,
      error: AppColors.error,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.night,
      textTheme: _textTheme(AppColors.nightText, AppColors.nightMuted),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.night,
        foregroundColor: AppColors.nightText,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.button,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sageGlow,
          textStyle: AppTypography.button,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.nightCard,
        selectedColor: AppColors.sageDark,
        labelStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.nightText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppColors.sageDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.nightCard,
        hintStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.nightMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sageDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sageDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sageGlow, width: 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.sage,
          selectedForegroundColor: AppColors.white,
          foregroundColor: AppColors.sageGlow,
          textStyle: AppTypography.label,
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color main, Color muted) {
    return TextTheme(
      displayLarge: AppTypography.display.copyWith(color: main),
      headlineMedium: AppTypography.headline.copyWith(color: main),
      titleLarge: AppTypography.title.copyWith(color: main),
      bodyLarge: AppTypography.body.copyWith(color: main),
      bodyMedium: AppTypography.bodySmall.copyWith(color: main),
      bodySmall: AppTypography.bodySmall.copyWith(color: muted),
      labelLarge: AppTypography.button.copyWith(color: main),
      labelSmall: AppTypography.label.copyWith(color: muted),
    );
  }
}
