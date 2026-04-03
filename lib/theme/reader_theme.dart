import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class ReaderTheme {
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.skyDeep, Color(0xFF060810)],
  );

  static final titleStyle = GoogleFonts.fraunces(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.cream,
    height: 1.25,
  );

  static final bodyStyle = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.cream.withAlpha(230),
    height: 1.85,
  );

  static const playerBackground = Color(0xFF080D1A);
}
