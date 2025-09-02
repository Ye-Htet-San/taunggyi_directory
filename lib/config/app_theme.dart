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
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
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
  );
}
