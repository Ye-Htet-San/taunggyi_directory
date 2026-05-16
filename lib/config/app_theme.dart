import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.textColor,
          displayColor: AppColors.textColor,
        ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.navInactive,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 5,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

//Dark Theme
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.darkTextColor,
          displayColor: AppColors.darkTextColor,
        ),
    cardColor: Color(0xFF1F1F2E), // Slightly lighter than background
    canvasColor: AppColors.darkBackground,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:Color(0xFF1F1F2E), //AppColors.darkBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.darkNavInactive,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 5,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.darkTextColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2A2A3D), // modern dark input field
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    // Optional: Elevated Cards with shadow for better visibility
    shadowColor: Colors.black54,
  );
}
