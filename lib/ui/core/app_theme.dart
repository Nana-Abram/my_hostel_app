import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimary = Color(0xFF2563EB);
  static const Color _lightSecondary = Color(0xFF16A34A);
  static const Color _lightAccent = Color(0xFFEAB308);
  static const Color _lightBackground = Colors.white;
  static const Color _lightSurface = Color(0xFFF8F9FA);
  static const Color _lightTextPrimary = Color(0xFF1F2937);
  static const Color _lightTextSecondary = Color(0xFF6B7280);

  // Dark Theme Colors
  static const Color _darkPrimary = Color(0xFF3B82F6);
  static const Color _darkSecondary = Color(0xFF22C55E);
  static const Color _darkAccent = Color(0xFFFBBF24);
  static const Color _darkBackground = Color(0xFF111827);
  static const Color _darkSurface = Color(0xFF1F2937);
  static const Color _darkTextPrimary = Color(0xFFF9FAFB);
  static const Color _darkTextSecondary = Color(0xFFD1D5DB);

  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        tertiary: _lightAccent,
        surface: _lightSurface,
        background: _lightBackground,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightTextPrimary,
        onBackground: _lightTextPrimary,
      ),

      scaffoldBackgroundColor: _lightBackground,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: _lightTextPrimary),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
      ),

      iconTheme: const IconThemeData(
        color: _lightTextPrimary,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: _lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _lightTextSecondary,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        tertiary: _darkAccent,
        surface: _darkSurface,
        background: _darkBackground,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkTextPrimary,
        onBackground: _darkTextPrimary,
      ),

      scaffoldBackgroundColor: _darkBackground,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: _darkTextPrimary),
      ),

      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
      ),

      iconTheme: const IconThemeData(
        color: _darkTextPrimary,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: _darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _darkTextSecondary,
        ),
      ),
    );
  }
}
