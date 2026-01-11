import 'package:flutter/material.dart';

ThemeData temaApp() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
    scaffoldBackgroundColor: const Color(0xFF0E0E10),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E0E10),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white60),
    ),
  );
}
