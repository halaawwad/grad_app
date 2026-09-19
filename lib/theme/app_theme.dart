import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final baseTheme = ThemeData.light();
    final baseText = baseTheme.textTheme.apply(
      fontFamily: 'Manrope',
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forest,
        brightness: Brightness.light,
      ),
      textTheme: baseText.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        displaySmall: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          height: 1.4,
          color: AppColors.ink,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          height: 1.4,
          color: const Color(0xFF556257),
        ),
        bodySmall: baseText.bodySmall?.copyWith(
          height: 1.35,
          color: const Color(0xFF6A766D),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shadowColor: AppColors.forest.withValues(alpha: 0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.sand.withValues(alpha: 0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.sand.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.forest, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cream,
        selectedColor: AppColors.forest,
        disabledColor: AppColors.sand,
        secondarySelectedColor: AppColors.forest,
        labelStyle: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData dark() {
    final baseTheme = ThemeData.dark();
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.leaf,
      brightness: Brightness.dark,
    );
    final baseText = baseTheme.textTheme.apply(
      fontFamily: 'Manrope',
      bodyColor: const Color(0xFFF5F0E6),
      displayColor: const Color(0xFFF5F0E6),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF162018),
      colorScheme: scheme,
      textTheme: baseText.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF5F0E6),
        ),
        displaySmall: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF5F0E6),
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF5F0E6),
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFFF5F0E6),
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFFF5F0E6),
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          height: 1.4,
          color: const Color(0xFFF5F0E6),
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          height: 1.4,
          color: const Color(0xFFD8D2C5),
        ),
        bodySmall: baseText.bodySmall?.copyWith(
          height: 1.35,
          color: const Color(0xFFBDB6A8),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF5F0E6),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF243128),
        shadowColor: Colors.black.withValues(alpha: 0.16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF243128),
        hintStyle: const TextStyle(color: Color(0xFFC5C0B2)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.sage, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF243128),
        selectedColor: AppColors.leaf,
        disabledColor: Colors.white24,
        secondarySelectedColor: AppColors.leaf,
        labelStyle: const TextStyle(
          color: Color(0xFFF5F0E6),
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF243128),
        indicatorColor: AppColors.leaf.withValues(alpha: 0.25),
        labelTextStyle: WidgetStatePropertyAll(
          baseText.labelMedium?.copyWith(color: const Color(0xFFF5F0E6)),
        ),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.1),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFFF5F0E6),
        textColor: Color(0xFFF5F0E6),
      ),
    );
  }
}
