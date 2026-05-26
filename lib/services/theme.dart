import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF3B82F6);       // Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF34D399);         // Mint/teal from logo
  static const Color accentLight = Color(0xFF6EE7B7);
  static const Color background = Color(0xFFF0F4FF);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color pendiente = Color(0xFFF59E0B);
  static const Color enProgreso = Color(0xFF3B82F6);
  static const Color completada = Color(0xFF10B981);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          color: Colors.white,
        ),
      );

  static Color estadoColor(String estado) {
    switch (estado) {
      case 'completada':
        return completada;
      case 'en_progreso':
        return enProgreso;
      default:
        return pendiente;
    }
  }

  static String estadoLabel(String estado) {
    switch (estado) {
      case 'completada':
        return 'Completada';
      case 'en_progreso':
        return 'En progreso';
      default:
        return 'Pendiente';
    }
  }

  static IconData estadoIcon(String estado) {
    switch (estado) {
      case 'completada':
        return Icons.check_circle_rounded;
      case 'en_progreso':
        return Icons.timelapse_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  static Color categoriaColor(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'cocina':
        return const Color(0xFFFF6B6B);
      case 'limpieza':
        return const Color(0xFF4ECDC4);
      case 'compras':
        return const Color(0xFFFFE66D);
      case 'jardín':
      case 'jardin':
        return const Color(0xFF95E1D3);
      case 'baño':
      case 'bano':
        return const Color(0xFFA8E6CF);
      default:
        return const Color(0xFFB0BEC5);
    }
  }
}
