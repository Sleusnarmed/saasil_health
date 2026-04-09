import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores 
  static const Color colorBackground = Color(0xFFF5F8F8);
  static const Color colorTextPrimary = Color(0xFF000000);
  static const Color colorTextSecondary = Color(0xFFFFFFFF);
  static const Color colorPrimary = Color(0xFF03045E);
  static const Color colorError = Color(0xFF9B2226);
  static const Color colorTertiary = Color(0xFFE36414);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colorBackground,
      colorScheme: const ColorScheme.light(
        primary: colorPrimary,
        secondary: colorTertiary,
        error: colorError,
        surface: colorBackground,
      ),
      
      textTheme: const TextTheme(
        // Títulos principales
        displayLarge: TextStyle(
          fontFamily: 'AlegreyaSans',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorTextPrimary,
        ),
        // Títulos de secciones
        titleLarge: TextStyle(
          fontFamily: 'AlegreyaSans',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: colorPrimary,
        ),
        // Subtítulos
        titleMedium: TextStyle(
          fontFamily: 'NunitoSans',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorTextPrimary,
        ),
        // Texto normal de lectura
        bodyLarge: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16,
          color: colorTextPrimary,
        ),
        // Texto pequeño o secundario
        bodySmall: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          color: Colors.black54,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          foregroundColor: colorTextSecondary,
          textStyle: const TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}