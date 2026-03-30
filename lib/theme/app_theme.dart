import 'package:flutter/material.dart';


class AppTheme {
  // \u2500\u2500\u2500 Brand Colors \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4B44CC);


  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFFFF6584);


  // \u2500\u2500\u2500 Neutral Palette \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const Color backgroundLight = Color(0xFFF8F7FF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color cardDark = Color(0xFF2A2A3E);


  // \u2500\u2500\u2500 Text Colors \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF1F1F9);
  static const Color textSecondaryDark = Color(0xFFA0A0B8);


  // \u2500\u2500\u2500 Priority Colors \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);


  // \u2500\u2500\u2500 Category Colors \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const Color catStudy = Color(0xFF6C63FF);
  static const Color catAssignment = Color(0xFFEC4899);
  static const Color catExam = Color(0xFFEF4444);
  static const Color catProject = Color(0xFFF59E0B);
  static const Color catPersonal = Color(0xFF10B981);
  static const Color catReading = Color(0xFF3B82F6);
  static const Color catOther = Color(0xFF8B5CF6);


  // \u2500\u2500\u2500 Gradient \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  // \u2500\u2500\u2500 Shadows \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static final  List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];


  static final  List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primaryColor.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];


  // \u2500\u2500\u2500 Light Theme \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceLight,
      background: backgroundLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimaryLight),
      titleTextStyle: TextStyle(
        color: textPrimaryLight,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundLight,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: CircleBorder(),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return primaryColor;
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: backgroundLight,
      selectedColor: primaryColor.withOpacity(0.15),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: Colors.grey.shade200),
    ),
  );


  // \u2500\u2500\u2500 Dark Theme \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryLight,
      secondary: secondaryColor,
      surface: surfaceDark,
      background: backgroundDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimaryDark),
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A3A52)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryLight, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondaryDark),
      hintStyle: const TextStyle(color: textSecondaryDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return primaryLight;
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Color(0xFF4A4A62), width: 1.5),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark,
      selectedColor: primaryLight.withOpacity(0.2),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
        color: textPrimaryDark,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: Color(0xFF3A3A52)),
    ),
  );
}