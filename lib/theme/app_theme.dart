import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  // true for Arabic-script locales (Arabic, Sorani Kurdish) — switches to a font
  // that actually renders Arabic glyphs, since Plus Jakarta Sans / Cormorant don't.
  static bool isArabicScript = false;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: isArabicScript ? GoogleFonts.vazirmatnTextTheme() : GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
    );
  }

  static TextStyle serif(double size, {FontWeight weight = FontWeight.w700, Color color = AppColors.ink}) {
    return isArabicScript
        ? GoogleFonts.vazirmatn(fontSize: size, fontWeight: weight, color: color)
        : GoogleFonts.lora(fontSize: size, fontWeight: weight, color: color);
  }

  static TextStyle sans(double size, {FontWeight weight = FontWeight.w500, Color color = AppColors.ink}) {
    return isArabicScript
        ? GoogleFonts.vazirmatn(fontSize: size, fontWeight: weight, color: color)
        : GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
  }
}
