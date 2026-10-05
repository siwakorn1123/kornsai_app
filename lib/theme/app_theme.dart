import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme({bool isLargeText = false}) {
    final double textScaleFactor = isLargeText ? 1.18 : 1.0;

    final baseTextTheme = GoogleFonts.promptTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.success,
        surface: AppColors.surface,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: (baseTextTheme.displayLarge?.fontSize ?? 32) * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 26) * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 22) * textScaleFactor,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: (baseTextTheme.titleLarge?.fontSize ?? 19) * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16) * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * textScaleFactor,
          color: AppColors.textDark,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * textScaleFactor,
          color: AppColors.textDark,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * textScaleFactor,
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF0EBE1), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontSize: (16 * textScaleFactor),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
