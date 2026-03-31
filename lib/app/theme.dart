import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D9E75)),
      scaffoldBackgroundColor: const Color(0xFFF6FAF8),
      useMaterial3: true,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1D9E75),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
