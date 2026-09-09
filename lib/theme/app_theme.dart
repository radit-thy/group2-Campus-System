import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF002045);
  static const Color orange = Color(0xFFFFB55C);
  static const Color lightBlue = Color(0xFFDCE9FF);
  static const Color paleBlue = Color(0xFFE5EEFF);
  static const Color iconBlue = Color(0xFFD3E4FE);
  static const Color textDark = Color(0xFF0B1C30);
  static const Color textGrey = Color(0xFF74777F);
  static const Color border = Color(0xFFC4C6CF);

  // Status colors (My Reports / Item Details badges)
  static const Color matchedBg = Color(0xFFFCE3B8);
  static const Color matchedText = Color(0xFF8A5A16);
  static const Color pendingBg = Color(0xFFDCE3F5);
  static const Color pendingText = Color(0xFF3D4A8A);
  static const Color claimedBg = Color(0xFFDFF3E4);
  static const Color claimedText = Color(0xFF1E7B3B);
  static const Color successGreen = Color(0xFF1E9E52);
  static const Color dangerRed = Color(0xFFD64545);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    scaffoldBackgroundColor: const Color(0xFFF8F9FF),

    colorScheme: ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.light,
      primary: navy,
      secondary: orange,
    ),

    fontFamily: 'Inter',

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FF),
      foregroundColor: navy,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        borderSide: BorderSide(
          color: border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        borderSide: BorderSide(
          color: border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        borderSide: BorderSide(
          color: navy,
          width: 1.5,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    scaffoldBackgroundColor: const Color(0xFF030405),

    colorScheme: ColorScheme.fromSeed(
      seedColor: orange,
      brightness: Brightness.dark,
      primary: orange,
      secondary: navy,
    ),

    fontFamily: 'Inter',
    

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF101820),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF0E141A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        borderSide: BorderSide(
          color: border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        borderSide: BorderSide(
          color: border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        borderSide: BorderSide(
          color: navy,
          width: 1.5,
        ),
      ),
    ),
  );
}