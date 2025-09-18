import 'package:flutter/material.dart';

class AppTheme {
  // --- الألوان الأساسية ---
  static const Color primaryColor = Colors.teal;
  static const Color accentColor = Colors.amber;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;

  // --- الثيم الكامل ---
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: primaryColor as MaterialColor, // قد تحتاج إلى تعريف MaterialColor مخصص
      scaffoldBackgroundColor: Colors.grey[50],
      fontFamily: 'Cairo',
      
      // تخصيص الـ AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),

      // تخصيص الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // تخصيص حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      
      // تخصيص الـ Chip
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        labelStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
