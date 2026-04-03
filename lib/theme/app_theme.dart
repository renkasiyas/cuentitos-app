import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Night sky palette (matching cuentitos.mx)
  static const skyDeep = Color(0xFF0B1026);
  static const nightBlue = Color(0xFF1A1F3A);
  static const nightMid = Color(0xFF141833);

  // Accent colors
  static const gold = Color(0xFFF5A623);
  static const goldLight = Color(0xFFFFD275);
  static const goldDim = Color(0x26F5A623); // 15% opacity

  // Warm colors
  static const terracotta = Color(0xFFE85D4A);
  static const sage = Color(0xFF7FB285);
  static const lavender = Color(0xFFB8A9C9);

  // Light surfaces
  static const cream = Color(0xFFFFF8E7);
  static const creamDark = Color(0xFFF5ECD7);

  // Semantic
  static const error = Color(0xFFE85D4A);
  static const success = Color(0xFF7FB285);
  static const warning = Color(0xFFF5A623);
}

class AppGradients {
  static const nightSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.skyDeep, AppColors.nightMid],
  );

  static const goldButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gold, Color(0xFFE89B1C)],
  );

  static const cardGlow = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [
      Color(0xE61A1F3A), // 90% opacity nightBlue
      Color(0xF2141833), // 95% opacity nightMid
    ],
  );
}

class AppTheme {
  static TextTheme get _textTheme => TextTheme(
    displayLarge: GoogleFonts.fraunces(fontSize: 48, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.5),
    displayMedium: GoogleFonts.fraunces(fontSize: 36, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.3),
    displaySmall: GoogleFonts.fraunces(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2),
    headlineLarge: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25),
    headlineMedium: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
    headlineSmall: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35),
    titleLarge: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4),
    titleMedium: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
    titleSmall: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
    bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
    bodyMedium: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
    bodySmall: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
    labelLarge: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2),
    labelMedium: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
    labelSmall: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: 0.5),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.skyDeep,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: AppColors.skyDeep,
      secondary: AppColors.goldLight,
      onSecondary: AppColors.skyDeep,
      surface: AppColors.nightBlue,
      onSurface: AppColors.cream,
      error: AppColors.terracotta,
      onError: AppColors.cream,
    ),
    textTheme: _textTheme.apply(bodyColor: AppColors.cream, displayColor: AppColors.cream),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.skyDeep.withAlpha(242),
      foregroundColor: AppColors.cream,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.cream),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.skyDeep,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cream,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: AppColors.cream.withAlpha(64), width: 2),
        textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.gold,
        textStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.cream.withAlpha(38)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.cream.withAlpha(38)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
      filled: true,
      fillColor: AppColors.nightBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.nunito(color: AppColors.cream.withAlpha(102)),
      labelStyle: GoogleFonts.nunito(color: AppColors.cream.withAlpha(179)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.skyDeep,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: Color(0xFF6B7280),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.nightBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.gold.withAlpha(31)),
      ),
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.goldDim,
      labelStyle: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldLight),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    dividerTheme: DividerThemeData(color: AppColors.cream.withAlpha(15)),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.nightBlue,
      contentTextStyle: GoogleFonts.nunito(color: AppColors.cream),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.gold,
      linearTrackColor: AppColors.goldDim,
    ),
    listTileTheme: ListTileThemeData(
      textColor: AppColors.cream,
      iconColor: AppColors.gold,
      titleTextStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.cream),
      subtitleTextStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.cream.withAlpha(179)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.nightBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.cream),
      contentTextStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.cream.withAlpha(204)),
    ),
  );
}
