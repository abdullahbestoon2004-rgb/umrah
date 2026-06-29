import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
    );
  }

  static TextStyle serif(double size, {FontWeight weight = FontWeight.w700, Color color = AppColors.ink}) {
    return GoogleFonts.cormorantGaramond(fontSize: size, fontWeight: weight, color: color);
  }

  static TextStyle sans(double size, {FontWeight weight = FontWeight.w500, Color color = AppColors.ink}) {
    return GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, color: color);
  }
}
