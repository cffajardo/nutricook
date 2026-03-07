import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color blushPink = Color(0xFFFF8BA7);
  static const Color rosePink = Color(0xFFF07C90);
  static const Color cream = Color(0xFFFAEEE7);
  static const Color cardRose = Color(0xFFF3E7E7);
  static const Color inputRose = Color(0xFFF5DCDC);
}

class AppTheme {
  static const LinearGradient authBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.blushPink, AppColors.cream, AppColors.blushPink],
    stops: [0.0, 0.5, 1.0],
  );

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.rosePink,
      secondary: AppColors.blushPink,
      surface: AppColors.cardRose,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      error: Colors.redAccent,
    );

    final comfortaaFamily = GoogleFonts.comfortaa().fontFamily;

    final comfortaaTextTheme = GoogleFonts.comfortaaTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: comfortaaFamily,
      textTheme: comfortaaTextTheme,
      primaryTextTheme: comfortaaTextTheme,
      scaffoldBackgroundColor: AppColors.blushPink,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blushPink,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardRose,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputRose,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rosePink, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.rosePink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.rosePink,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.rosePink,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
