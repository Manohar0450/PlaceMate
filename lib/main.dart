import 'package:flutter/material.dart';
import 'package:placemate/DevelopmentTeamPage.dart';
import 'SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ThemeMode.system,
      // home:  DevelopmentTeamPage(),
      home:  SplashScreen(),
    );
  }
}

/* ---------------- LIGHT THEME ---------------- */

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF3B82F6),
    background: Color(0xFFF6F8FC),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSurface: Colors.black,
  ),
  scaffoldBackgroundColor: const Color(0xFFF6F8FC),
  cardColor: Colors.white,

  // Set every text style to w900 (Extra Bold)
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w900),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w900),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    prefixIconColor: const Color(0xFF6B7280),
    // Ensures hint text is also bold
    hintStyle: const TextStyle(fontWeight: FontWeight.w900),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3B82F6),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
);

/* ---------------- DARK THEME ---------------- */

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6C9EFF),
    background: Color(0xFF0B1220),
    surface: Color(0xFF111827),
    onPrimary: Colors.black,
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF0B1220),
  cardColor: const Color(0xFF111827),

  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w900),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w900),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF111827),
    prefixIconColor: const Color(0xFF9CA3AF),
    hintStyle: const TextStyle(fontWeight: FontWeight.w900),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF1F2937)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF1F2937)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF6C9EFF)),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C9EFF),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF1F2937), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    ),
  ),
);